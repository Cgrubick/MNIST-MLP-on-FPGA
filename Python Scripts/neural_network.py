import os
import torch
from torchvision import datasets, transforms
from PIL import Image
from torch.utils.data import DataLoader, Dataset
from torch import nn
import numpy as np
class BinarizedMNISTDataset(Dataset):
    def __init__(self, dataset, output_folder):
        self.dataset = dataset
        self.output_folder = output_folder
        self._prepare_dataset()

    def __len__(self):
        return len(self.dataset)

    def __getitem__(self, idx):
        img, label = self.dataset[idx]
        img = (np.array(img) >= 0.5).astype(np.uint8) * 255  # Binarize: 0 or 255
        img = img.squeeze()  # Ensure shape is (28, 28)
        img = Image.fromarray(img, mode='L')  # Convert to grayscale (mode 'L')
        return img, label

    def _prepare_dataset(self):
        # Check if the folder already exists and is not empty
        if os.path.exists(self.output_folder) and any(
            os.scandir(self.output_folder)
        ):
            print(f"Images already exist in {self.output_folder}. Skipping processing.")
            return

        print(f"Processing and saving images to {self.output_folder}...")
        os.makedirs(self.output_folder, exist_ok=True)

        for idx in range(len(self.dataset)):
            img, label = self[idx]
            label_folder = os.path.join(self.output_folder, str(label))
            os.makedirs(label_folder, exist_ok=True)

            img.save(os.path.join(label_folder, f"{idx}.png"))

# Load the original MNIST dataset
original_transform = transforms.Compose([transforms.ToTensor()])
trainset = datasets.MNIST(root='./data', train=True, download=True, transform=original_transform)
testset = datasets.MNIST(root='./data', train=False, download=True, transform=original_transform)

# Create binarized dataset and save to folders
train_folder = './binarized_train'
test_folder = './binarized_test'

binarized_train = BinarizedMNISTDataset(trainset, train_folder)
binarized_test = BinarizedMNISTDataset(testset, test_folder)

print(f"Binarized images saved to:\nTrain: {train_folder}\nTest: {test_folder}")

# Step 2: Define a custom transform to load binarized images
class LoadBinarizedDataset(Dataset):
    def __init__(self, folder):
        self.folder = folder
        self.image_paths = []
        self.labels = []
        self._load_paths()

    def _load_paths(self):
        for label in os.listdir(self.folder):
            label_folder = os.path.join(self.folder, label)
            if os.path.isdir(label_folder):
                for img_file in os.listdir(label_folder):
                    self.image_paths.append(os.path.join(label_folder, img_file))
                    self.labels.append(int(label))

    def __len__(self):
        return len(self.image_paths)

    def __getitem__(self, idx):
        img_path = self.image_paths[idx]
        img = Image.open(img_path).convert('L')
        img = transforms.ToTensor()(img)
        label = self.labels[idx]
        return img, label

# Load binarized datasets
train_dataset = LoadBinarizedDataset(train_folder)
test_dataset = LoadBinarizedDataset(test_folder)

train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)

# Step 3: Train the Model on Binarized Data
class SimpleNN(nn.Module):
    def __init__(self):
        super(SimpleNN, self).__init__()
        self.fc1 = nn.Linear(28 * 28, 5)
        self.fc2 = nn.Linear(5, 10)

    def forward(self, x):
        x = x.view(-1, 28 * 28)
        x = torch.relu(self.fc1(x))
        x = self.fc2(x)
        return torch.softmax(x, dim=1)

# Create model, loss function, and optimizer
model = SimpleNN()
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

# Training loop
epochs = 5
for epoch in range(epochs):
    model.train()
    running_loss = 0
    for images, labels in train_loader:
        optimizer.zero_grad()
        output = model(images)
        loss = criterion(output, labels)
        loss.backward()
        optimizer.step()
        running_loss += loss.item()
    print(f"Epoch [{epoch + 1}/{epochs}], Loss: {running_loss / len(train_loader):.4f}")

# Test the model
def calculate_accuracy(model, dataloader):
    model.eval()
    correct = 0
    total = 0
    with torch.no_grad():
        for images, labels in dataloader:
            output = model(images)
            _, predicted = torch.max(output, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
    return correct / total * 100

train_accuracy = calculate_accuracy(model, train_loader)
test_accuracy = calculate_accuracy(model, test_loader)

print(f"Training Accuracy: {train_accuracy:.2f}%")
print(f"Testing Accuracy: {test_accuracy:.2f}%")
