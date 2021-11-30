README
================

## Deep Vector Autoregression for Macroeconomic Data

### Paper Abstract

*Vector Autoregression is a popular choice for forecasting time series
data. Due to its simplicity and success at modelling monetary economic
indicators VAR has become a standard tool for central bankers to
construct economic forecasts. A crucial assumption underlying the
conventional VAR is that interactions between variables through time can
be modelled linearly. We propose Deep VAR: a novel approach towards VAR
that leverages the power of deep learning in order to model non-linear
relatonships. By modelling each equation of the VAR system as a deep
neural network, our proposed extension outperforms its conventional
benchmark in terms of in-sample fit, out-of-sample fit and point
forecasting accuracy. In particular, we find that the Deep VAR is able
to better capture the structural economic changes during periods of
uncertainty and recession. By staying methodologically as close as
possible to the original benchmark, we hope that our approach is more
likely to find acceptance in the economics domain.*

## Pointers

A few useful pointers:

1.  [Paper](paper/paper.pdf)
2.  [Slides](presentation/presentation.pdf)
3.  [Poster](poster/poster.html)
4.  [R Package](https://github.com/pat-alt/deepvars)

## Citation

Please cite the related working paper as follows:

    @article{altmeyer2021deep,
        author = {Altmeyer, Patrick and Agusti, Marc and Vidal-Quadras Costa, Ignacio},
        date-added = {2021-09-23 13:33:59 +0200},
        date-modified = {2021-11-30 16:33:49 +0100},
        title = {Deep Vector Autoregression for Macroeconomic Data},
        url = {https://thevoice.bse.eu/wp-content/uploads/2021/07/ds21-project-agusti-et-al.pdf},
        year = {2021}}

Please cite this package as follows:

    @Manual{altmeyer2021deepvars,
      title = {deepvars: Deep Vector Autoregression},
      author = {Patrick Altmeyer},
      note = {R package version 0.1.0}}
