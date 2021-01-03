---
title: "Controlling for multiple spatial lags is (computationally) hard"
output:
  md_document
author: "Keith Barnatchez"
date: "2019-02-12T13:43:40"
comments: true
---

*This post is primarily about spatial models. If you are unfamiliar with these types of models, read my primer here.*

Spatial modeling has expanded beyond distance-based notions of space into other, more abstract measures of proximity, such as trade between countries or flights between states. Naturally, we may want to include multiple measures of proximity in a spatial model, which means multiple weighting matrices. Imagine we're trying to model coronavirus cases at the state level. It makes sense that neighboring states could influence each other's case levels, but it's also possible that states with high levels of air travel (e.g. Massachusetts and Florida) could exhibit similar patterns of influence.

If we let $y$ denote the number of cases in a state, $C$ be a row-normalized contiguity weighting matrix and $F$ be a row-normalized matrix of passenger-weighted flights between states, then a simple spatial model would be:

$$
y = \rho_1 C y + \rho_2 F y  + \varepsilon
$$

As we know, we can rewrite this as

$$
y = (I - \rho _1 C - \rho_2 W)^{-1} \varepsilon,
$$
which can be estimated via MLE. While there is nothing wrong in principle with including two weighting matrices, it turns out that this slows down the MLE computation tremendously. To see why, we'll look at the likelihood function and its related computation algorithms.

### The likelihood function
Assuming normality of $\varepsilon$, we know that 

$$
\begin{aligned}
L(\varepsilon) &= \prod_{i=1}^N \frac{1}{\sqrt{2\pi \sigma^2}} e^{-\frac{1}{2}\left(\frac{\varepsilon_i}{\sigma}\right)^2 } \\\\\\
&= \left(\frac{1}{2\pi \sigma^2} \right)^{N/2} e^{\frac{N}{2\sigma^2}\sum_{i=1}^{N}\varepsilon_i^2} \\\\\\
&= \left(\frac{1}{2\pi \sigma^2} \right)^{N/2} e^{\frac{N}{2\sigma^2}\varepsilon' \varepsilon}
\end{aligned} 
$$

In turn, the log likelihood is

$$
\text{log}L(\varepsilon) = -\frac{N}{2}\log2\pi - N\log\sigma - \frac{1}{2\sigma^2}\varepsilon'\varepsilon 
$$

Now, we don't observe $\varepsilon$ but we do observe $y$. It's tempting to just replace $\varepsilon$ with $y - X\beta$ in the log-likelihood above, but this is not correct. Recall that if we know the density for some random variable $x_1$ to be $f_{x_1}(x_1)$, and we know some other variable $x_2$ is related to $x_1$ by $x_1 = g(x_2)$, then $f_{x_2} = f_{x_1}(g(x_2))\text{det}(J_{x_2})$, where $J_{x_2}$ is the Jacobian of $g$ with respect to $x_2$. In our case, 
$$
\varepsilon = (I - \rho_1 C - \rho_2 F)y - X\beta
$$
so that the Jacobian is $(I - \rho_1 C - \rho_2 F)$.

### A quick algorithm for computing the likelihood
In the case of a simple spatial model (just one weighting matrix $W$), the log-likelihood is
$$
\text{log}L(y|X) = -\frac{N}{2}\log2\pi - N\log\sigma - \frac{1}{2\sigma^2}(y - X\beta)'(y - X\beta) + \log \det(I-\rho W)
$$
Computationally, this becomes a pain when we have to compute the log determinant term for every iteration of the MLE procedure. Depending on the size of our cross-section, the computation of this term alone can slow things down considerably if we use brute force methods. Luckily, there are much faster ways to go about this than directly computing the determinant.

You may remember that the *characteristic polynomial* of an $N \times N$ matrix $W$ with eigenvalues $\lambda_1,\ldots,\lambda_N$ is given by 
$$
f(\lambda) := \det(W-\lambda I) =   (\lambda_1 - \lambda)\ldots(\lambda_N-\lambda)
$$
Now, if use the fact that $\det(\alpha M) = \alpha^N \det(M)$ for any $N \times N$ matrix $M$, and let $\rho=\frac{1}{\lambda}$, then 
$$
\det(I - \rho W) = (-\rho)^N \det(W - \lambda I) = (-\rho)^N (\lambda_1 - \rho^{-1})\ldots (\lambda_N - \rho^{-1})
$$
We just need to calculate the eigenvalues of $W$ once, and then our determinant of interest ends up just being a much easier to compute function of the eigenvalues and $\rho$. Given that we need to iterate over different values of $\rho$, this can be huge for reducing computation time.

### The issue with multiple weighting matrices
As soon as we add a second weighting matrix, we can no longer use this characteristic polynomial approach to calculate the log determinant term of the likelihood.

