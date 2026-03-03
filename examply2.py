import numpy as np
import matplotlib.pyplot as plt
import os

project_root = r"C:\Users\masgh\emg-project"
# Create a 'figures' folder inside the project if it doesn't exist
figures_dir = os.path.join(project_root, "figures")
os.makedirs(figures_dir, exist_ok=True)  # exist_ok=True avoids error if folder exists

# Generate time points
t = np.linspace(0, 2*np.pi, 500)

# Create a sine wave with noise
y = np.sin(2 * t) + 0.2 * np.random.randn(len(t))

# Plot
plt.figure(figsize=(8,4))
plt.plot(t, y, label='Noisy Sine Wave')
plt.plot(t, np.sin(2 * t), '--', label='Clean Sine Wave')
plt.title("Simple Plot Example")
plt.xlabel("Time")
plt.ylabel("Amplitude")
plt.legend()
plt.grid(True)

# Save the plot as a PNG
plt.savefig(os.path.join(figures_dir, "example_plot.png"), dpi=150)  # dpi controls resolution
plt.close()
print("Plot saved as 'example_plot.png'")