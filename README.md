README
================

# navar

## To-do

  - Bibtex bibliography (Macos, use for example Bibdesk)
  - Go through NAVAR code and reproduce experiments:
    <https://github.com/bartbussmann/NAVAR> - I have added that code as
    a folder to this repo. Code looks straight-forward, but should all
    spend some time going through it to really understand what is going
    on. - CHECK: is the training function really well set up?

## References

### Timesteps

  - <https://machinelearningmastery.com/use-timesteps-lstm-networks-time-series-forecasting/>
  - <https://medium.com/@dclengacher/lstms-with-lagged-data-cc03a3a8cfcf>
  - <https://shiva-verma.medium.com/understanding-input-and-output-shape-in-lstm-keras-c501ee95c65e>
  - <https://karpathy.github.io/2015/05/21/rnn-effectiveness/>
  - <https://stats.stackexchange.com/questions/377091/time-steps-in-keras-lstm>
  - <https://machinelearningmastery.com/reshape-input-data-long-short-term-memory-networks-keras/>

## Structure

1.  Literature review:
      - Literature on forecasting time series
      - Literature on high-dimensinoal data: BoE paper(s); ECB?
      - Monetary transmission mechanism: VAR, BVAR, SVAR
      - Check “Related work” section in Bussmann, Nys, and Latré (2020)
      - Neural networks for time series forecasting
2.  Introduction:
      - What?
      - Theoretical framework: VAR vs. NAVAR?
      - Empirical approach
3.  Methodology
      - VAR
      - NAVAR
4.  Data
5.  Benchmark exercises
      - Point, interval and density forecasts
      - Granger causality
      - IRFs
      - Forecasting evaluation: DM, forecasting combination
6.  Extensions
      - Forward guidance?
      - QE?
7.  Conclusions

# References

<div id="refs" class="references">

<div id="ref-bussmann2020neural">

Bussmann, Bart, Jannes Nys, and Steven Latré. 2020. “Neural Additive
Vector Autoregression Models for Causal Discovery in Time Series Data.”
*arXiv Preprint arXiv:2010.09429*.

</div>

</div>
