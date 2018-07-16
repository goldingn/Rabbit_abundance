
all: prepped_data.Rdata models figures  paper

clean:
	rm -f *.Rdata;\
	rm -f Figures/raneff_violin_foxes.pdf Figures/beta_posterior_density.pdf Figures/sigma_posterior_density.pdf Figures/raneff_violin_rabbits.pdf  Figures/predicted_fox_r.pdf Figures/fox_abund.pdf Figures/rabbit_abund.pdf Figures/beta_traceplots.pdf Figures/rain_graph.pdf;\
	rm -f Fox_model_paper.pdf

#metarule to fit the models
models: Fitted_rain_model.Rdata

#metarule to make the figures
figures: Figures/beta_posterior_density.pdf Figures/predicted_fox_r.pdf Figures/fox_abund.pdf Figures/rain_graph.pdf Figures/raneff_violin.pdf  Figures/beta_traceplots.pdf Figures/PPcheck.pdf

#metarule to make the paper
paper: Fox_model_paper.docx Fox_model_paper.pdf

###############################################################################	
#clean and tidy the data, and save to an Rdata file                           #
###############################################################################	
prepped_data.Rdata: Data/spotlight_data.csv Data/AllRain.csv R/prep_data.R
	Rscript R/prep_data.R

###############################################################################	
#Run the state-space models and save the results                               #
###############################################################################
Fitted_rain_model.Rdata: R/run_model_rain.R prepped_data.Rdata  R/GHR_distlag_rain.txt 
	Rscript $^ $@    
	
PREF_RESULT = Fitted_rain_model.Rdata
###############################################################################	
#generate the figures as pdfs                                                 #
###############################################################################
Figures/beta_posterior_density.pdf: R/beta_posterior_density.R Fitted_rain_model.Rdata
	Rscript $^ $@
	
Figures/predicted_fox_r.pdf: R/predicted_fox_r.R Fitted_rain_model.Rdata
	Rscript $^ $@
	
Figures/fox_abund.pdf: R/pred_abund.R Fitted_rain_model.Rdata Data/ripping_data.csv
	Rscript $^ $@
	
###############################################################################	
#generate the supplementary figures                                           #
###############################################################################

Figures/rain_graph.pdf: R/rain_graph.R Fitted_rain_model.Rdata
	Rscript $^ $@
	
Figures/raneff_violin.pdf: R/raneff_violin.R Fitted_rain_model.Rdata
	Rscript $^ $@

Figures/PPcheck.pdf: R/PP_check.R  Fitted_rain_model.Rdata
	Rscript $^
	
###############################################################################	
#generate diagnostic plots                                                    #
###############################################################################

Figures/beta_traceplots.pdf: R/diagnostic_plots.R Fitted_rain_model.Rdata
	Rscript $^

###############################################################################	
#generate the paper as a pdf document                                         #
###############################################################################
Fox_model_paper.pdf: R/render_script.R Fox_model_paper.Rmd rabbit_refs.bib models figures 
	Rscript R/render_script.R pdf_document
