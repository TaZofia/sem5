import numpy as np
import matplotlib.pyplot as plt

def f(x):
    return np.exp(x) * np.log(1 + np.exp(-x))

x = np.linspace(0, 50, 500)
y = f(x)

plt.figure()
plt.plot(x, y)
plt.xlabel("x")
plt.ylabel("f(x)")
plt.grid(True)
plt.show()
