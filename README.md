README
================

# navar

## To-do

**Finish by Tuesday:**

*Marc*:

-   Bibtex bibliography (Macos, use for example Bibdesk):
    -   add references from lit review

    1.  Download [BibDesk](https://bibdesk.sourceforge.io/)
    2.  Open [bib.bib](bib.bib)
    3.  Inside any of our markdown (.Rmd) documents, use citation key to
        cite, for example: @pfaff2008var will turn into Pfaff and
        others (2008). If you want brackets around it, the write
        \[@pfaff2008var\] which will look as follows (Pfaff and
        others 2008).

*Ignacio*:

-   Get UK data (\*)
-   Double-check US data (CPI now poorly defined, interest rate?)
    -   update the preprocessing for this
        [preprocessing.Rmd](preprocessing.Rmd)

*Pat*:

-   Polish the package functionality

**Rest of the week:**

-   Use code for model comparison: VAR, MLSTM (preferred VAR-type),
    MLSTM (timestamps for lags)
    -   compare insample MSE, cumulative loss (Pat to add functionality)
    -   Diebold Mariano
    -   provide anecdotal evidence of where/when the MLSTM performs
        better:
        -   train-test split
            1.  train-test split the pre-covid data
            2.  train on pre-covide, test on post-covid
        -   out-of-sample forecasts - covid (\*)
-   Section on interpretability and other approaches (links to NAVAR and
    Verstyuk)
    -   Show IRFs, FEVD, etc. from SVAR, talk to the intuition and
        highlight shortfalls of deep learning approach also linking to
        NAVAR and Verstyuk.
    -   Impulse response function (\*)

**By end of week have a draft ready!!!**

## References

### Timesteps

-   <https://machinelearningmastery.com/use-timesteps-lstm-networks-time-series-forecasting/>
-   <https://medium.com/@dclengacher/lstms-with-lagged-data-cc03a3a8cfcf>
-   <https://shiva-verma.medium.com/understanding-input-and-output-shape-in-lstm-keras-c501ee95c65e>
-   <https://karpathy.github.io/2015/05/21/rnn-effectiveness/>
-   <https://stats.stackexchange.com/questions/377091/time-steps-in-keras-lstm>
-   <https://machinelearningmastery.com/reshape-input-data-long-short-term-memory-networks-keras/>

## Structure

1.  Literature review:
    -   Literature on forecasting time series
    -   Literature on high-dimensinoal data: BoE paper(s); ECB?
    -   Monetary transmission mechanism: VAR, BVAR, SVAR
    -   Check “Related work” section in Bussmann, Nys, and Latré (2020)
    -   Neural networks for time series forecasting
2.  Introduction:
    -   What?
    -   Theoretical framework: VAR vs. NAVAR?
    -   Empirical approach
3.  Methodology
    -   VAR
    -   NAVAR
4.  Data
5.  Benchmark exercises
    -   Point, interval and density forecasts
    -   Granger causality
    -   IRFs
    -   Forecasting evaluation: DM, forecasting combination
6.  Extensions
    -   Forward guidance?
    -   QE?
7.  Conclusions

# References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-bussmann2020neural" class="csl-entry">

Bussmann, Bart, Jannes Nys, and Steven Latré. 2020. “Neural Additive
Vector Autoregression Models for Causal Discovery in Time Series Data.”
*arXiv Preprint arXiv:2010.09429*.

</div>

<div id="ref-pfaff2008var" class="csl-entry">

Pfaff, Bernhard, and others. 2008. “VAR, SVAR and SVEC Models:
Implementation Within r Package Vars.” *Journal of Statistical Software*
27 (4): 1–32.

</div>

</div>
