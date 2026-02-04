"""
Training Pipeline for Food Recognition Model
EfficientNetV2 with PyTorch
"""

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms, models
from torchvision.datasets import ImageFolder
from tqdm import tqdm
import wandb
import json
from pathlib import Path

# Configuration
class Config:
    # Model
    MODEL_NAME = 'efficientnet_v2_s'
    NUM_CLASSES = 100  # Adjust based on your dataset
    INPUT_SIZE = 224
    
    # Training
    BATCH_SIZE = 32
    EPOCHS = 100
    LEARNING_RATE = 0.001
    WEIGHT_DECAY = 1e-4
    
    # Paths
    DATA_DIR = './dataset'
    SAVE_DIR = './models'
    
    # Device
    DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'
    
    # Early stopping
    PATIENCE = 10


class FoodRecognitionModel(nn.Module):
    """EfficientNetV2 for food recognition"""
    
    def __init__(self, num_classes=100):
        super().__init__()
        # Load pre-trained EfficientNetV2
        self.model = models.efficientnet_v2_s(pretrained=True)
        
        # Replace classifier
        in_features = self.model.classifier[1].in_features
        self.model.classifier = nn.Sequential(
            nn.Dropout(p=0.3),
            nn.Linear(in_features, num_classes)
        )
    
    def forward(self, x):
        return self.model(x)


class FoodDataset(Dataset):
    """Custom dataset with nutrition data"""
    
    def __init__(self, root_dir, transform=None):
        self.dataset = ImageFolder(root_dir, transform=transform)
        self.nutrition_db = self._load_nutrition_db()
    
    def _load_nutrition_db(self):
        # Load nutrition database
        with open('nutrition_db.json', 'r') as f:
            return json.load(f)
    
    def __len__(self):
        return len(self.dataset)
    
    def __getitem__(self, idx):
        image, label = self.dataset[idx]
        food_name = self.dataset.classes[label]
        nutrition = self.nutrition_db.get(food_name, {})
        
        return {
            'image': image,
            'label': label,
            'nutrition': nutrition
        }


def get_transforms():
    """Data augmentation transforms"""
    
    train_transform = transforms.Compose([
        transforms.RandomResizedCrop(Config.INPUT_SIZE),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(20),
        transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    val_transform = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(Config.INPUT_SIZE),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    return train_transform, val_transform


def train_epoch(model, dataloader, criterion, optimizer, device):
    """Train for one epoch"""
    
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0
    
    pbar = tqdm(dataloader, desc='Training')
    for batch in pbar:
        images = batch['image'].to(device)
        labels = batch['label'].to(device)
        
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        
        running_loss += loss.item()
        _, predicted = outputs.max(1)
        total += labels.size(0)
        correct += predicted.eq(labels).sum().item()
        
        pbar.set_postfix({
            'loss': running_loss / (pbar.n + 1),
            'acc': 100. * correct / total
        })
    
    return running_loss / len(dataloader), 100. * correct / total


def validate(model, dataloader, criterion, device):
    """Validate the model"""
    
    model.eval()
    running_loss = 0.0
    correct = 0
    total = 0
    
    with torch.no_grad():
        for batch in tqdm(dataloader, desc='Validation'):
            images = batch['image'].to(device)
            labels = batch['label'].to(device)
            
            outputs = model(images)
            loss = criterion(outputs, labels)
            
            running_loss += loss.item()
            _, predicted = outputs.max(1)
            total += labels.size(0)
            correct += predicted.eq(labels).sum().item()
    
    return running_loss / len(dataloader), 100. * correct / total


def main():
    """Main training function"""
    
    # Initialize wandb
    wandb.init(project='find-your-food', config=vars(Config))
    
    # Create save directory
    Path(Config.SAVE_DIR).mkdir(parents=True, exist_ok=True)
    
    # Prepare data
    train_transform, val_transform = get_transforms()
    
    train_dataset = FoodDataset(
        f'{Config.DATA_DIR}/train',
        transform=train_transform
    )
    val_dataset = FoodDataset(
        f'{Config.DATA_DIR}/val',
        transform=val_transform
    )
    
    train_loader = DataLoader(
        train_dataset,
        batch_size=Config.BATCH_SIZE,
        shuffle=True,
        num_workers=4,
        pin_memory=True
    )
    val_loader = DataLoader(
        val_dataset,
        batch_size=Config.BATCH_SIZE,
        shuffle=False,
        num_workers=4,
        pin_memory=True
    )
    
    # Initialize model
    model = FoodRecognitionModel(num_classes=Config.NUM_CLASSES)
    model = model.to(Config.DEVICE)
    
    # Loss and optimizer
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.AdamW(
        model.parameters(),
        lr=Config.LEARNING_RATE,
        weight_decay=Config.WEIGHT_DECAY
    )
    scheduler = optim.lr_scheduler.CosineAnnealingLR(
        optimizer,
        T_max=Config.EPOCHS
    )
    
    # Training loop
    best_acc = 0.0
    patience_counter = 0
    
    for epoch in range(Config.EPOCHS):
        print(f'\nEpoch {epoch+1}/{Config.EPOCHS}')
        
        # Train
        train_loss, train_acc = train_epoch(
            model, train_loader, criterion, optimizer, Config.DEVICE
        )
        
        # Validate
        val_loss, val_acc = validate(
            model, val_loader, criterion, Config.DEVICE
        )
        
        scheduler.step()
        
        # Log to wandb
        wandb.log({
            'epoch': epoch,
            'train_loss': train_loss,
            'train_acc': train_acc,
            'val_loss': val_loss,
            'val_acc': val_acc,
            'lr': optimizer.param_groups[0]['lr']
        })
        
        print(f'Train Loss: {train_loss:.4f} | Train Acc: {train_acc:.2f}%')
        print(f'Val Loss: {val_loss:.4f} | Val Acc: {val_acc:.2f}%')
        
        # Save best model
        if val_acc > best_acc:
            best_acc = val_acc
            patience_counter = 0
            
            torch.save({
                'epoch': epoch,
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'val_acc': val_acc,
                'class_names': train_dataset.dataset.classes
            }, f'{Config.SAVE_DIR}/best_model.pth')
            
            print(f'✓ Best model saved (Val Acc: {val_acc:.2f}%)')
        else:
            patience_counter += 1
        
        # Early stopping
        if patience_counter >= Config.PATIENCE:
            print(f'\nEarly stopping triggered after {epoch+1} epochs')
            break
    
    print(f'\nTraining complete! Best Val Acc: {best_acc:.2f}%')


if __name__ == '__main__':
    main()
