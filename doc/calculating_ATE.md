# ****Calculating an ATE****

The average treatment effect (ATE) measures the difference in mean (average) outcomes between “baseline” cases and the “experimental" cases. 

In the event that you will be providing the average treatment effect (ATE) for your AI model, the AIR Tool will accept ATE values calculated using potential outcome prediction. The calculation is relatively simple. In practice, you cannot observe both $Y_{1}$​ (observed treated outcome) and $Y_{0}$​ (observed untreated outcome) for the same individual, so we will rely on the model to simulate these outcomes for us. 

For each individual data point in the dataset, we first calculate the potential outcomes as:

-   ${\widehat{Y}}_{1}$: the predicted outcome where the treatment value for all individuals is manually set to 1 ($T = 1$).

-   ${\widehat{Y}}_{0}$: the predicted outcome where the treatment value for all individuals is manually set to 0 ($T = 0$).

Next, we use these predicted outcomes to calculate ATE. This value is
simply the average difference between the two potential outcomes:

$$ATE = \frac{1}{N}\sum_{i = 1}^{N}{({\widehat{Y}}_{1i} - \ {\widehat{Y}}_{0i})}\ $$
