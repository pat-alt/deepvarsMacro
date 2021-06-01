README
================

# navar

## To-do

  - **Abstract**
  - Polish **literature review**; turn into more of an introduction +
    lit review
  - Section on **Data** (Ignacio)
  - Section on **Methodology** (Pat)
  - Section on **Empirical Findings** (everyone, Marc to start)
      - Use package for model comparison: VAR, MLSTM (preferred
        VAR-type), MLSTM (timestamps for lags)
          - compare insample MSE, cumulative loss (Pat to add
            functionality)
          - Diebold Mariano
          - provide anecdotal evidence of where/when the MLSTM performs
            better:
              - train-test split
                1.  train-test split the pre-covid data
                2.  train on pre-covide, test on post-covid
              - out-of-sample forecasts - covid (\*)
  - Section on **Caveats, Interpretability and Extensions** (links to
    NAVAR and Verstyuk)
      - Show IRFs, FEVD, etc. from SVAR, talk to the intuition and
        highlight shortfalls of deep learning approach also linking to
        NAVAR and Verstyuk.
      - Impulse response function (\*)
  - **Conclusion**

*Marc*:

  - Bibtex bibliography (Macos, use for example Bibdesk):
      - add references from lit review
    <!-- end list -->
    1.  Download [BibDesk](https://bibdesk.sourceforge.io/)
    2.  Open [bib.bib](bib.bib)
    3.  Inside any of our markdown (.Rmd) documents, use citation key to
        cite, for example: @pfaff2008var will turn into Pfaff and others
        (2008). If you want brackets around it, the write
        \[@pfaff2008var\] which will look as follows (Pfaff and others
        2008).

*Ignacio*:

  - Get UK data (\*)
  - Double-check US data (CPI now poorly defined, interest rate?)
      - update the preprocessing for this
        [preprocessing.Rmd](preprocessing.Rmd)

## `deepvars` package

> Now done. Repo for package is [here](). To install simply run:

``` r
devtools::install_github("pat-alt/deepvars", build_vignettes=TRUE)
```

> Then to see how everything works simply look at the vignette about
> deep vars:

``` r
library(deepvars)
browseVignettes("deepvars")
```

## References

### Timesteps

  - <https://machinelearningmastery.com/use-timesteps-lstm-networks-time-series-forecasting/>
  - <https://medium.com/@dclengacher/lstms-with-lagged-data-cc03a3a8cfcf>
  - <https://shiva-verma.medium.com/understanding-input-and-output-shape-in-lstm-keras-c501ee95c65e>
  - <https://karpathy.github.io/2015/05/21/rnn-effectiveness/>
  - <https://stats.stackexchange.com/questions/377091/time-steps-in-keras-lstm>
  - <https://machinelearningmastery.com/reshape-input-data-long-short-term-memory-networks-keras/>

# References

<div id="refs" class="references">

<div id="ref-pfaff2008var">

Pfaff, Bernhard, and others. 2008. “VAR, Svar and Svec Models:
Implementation Within R Package Vars.” *Journal of Statistical Software*
27 (4): 1–32.

</div>

</div>
