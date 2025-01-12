library(shiny)
library(treeio)
library(ggtree)
library(ggplot2)
library(ggimage)
library(aplot)
source('helper.R')

drawtree <- function (tr) {
  ggtree(
    tr, 
    layout = "roundrect",
    color = "navyblue",
    size = 1,
    ladderize = TRUE
  ) + 
    geom_tiplab(colour = "navyblue",
                size = 2, offset=0.2,
                align = T) +
    geom_tippoint(color = "orange", size = 1) +
    geom_rootedge(color = "navyblue", size = 1) +
    theme_tree2() + xlim(0, max(tr$edge.length) + 2)
}

drawhm <- function (hm, x, y) {
  ggplot(hm, aes_string(x, y)) +
    geom_tile(aes(fill = Value)) + scale_fill_viridis_c() +
    theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(),
          axis.text.x = element_text(
            angle = 90,
            hjust = 1,
            vjust = 0.5
          ))
} 

drawbar <- function (bar, x, y) {
  ggplot(bar, aes_string(x, y)) +
    geom_col(aes(fill = Group)) +
    coord_flip() +
    scale_fill_viridis_d(option="D", name="discrete\nvalue")+
    theme(axis.ticks.y = element_blank(), axis.text.y = element_blank()) +
    theme(
      panel.background = element_rect(fill='transparent'),
      plot.background = element_rect(fill='transparent', color=NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      legend.background = element_rect(fill='transparent'),
      legend.box.background = element_rect(fill='transparent')
    )
}

draw1 <- function(data) {
  if (data$type == 'tree') {
    drawtree(data$data)
  } else if (data$type == 'heatmap') {
    drawhm(data$data, x = data$x, y = data$y)
  } else if (data$type == 'barplot') {
    drawbar(data$data, x = data$y, y = data$x)
  }
}

assignOrder <- function(data) {
  save(data, file="data.Rdata")
  for (i in seq_along(data)) {
    if (data[[i]]$type=='tree') {
      data[[i]]$order=1
    } else if (data[[i]]$type=='heatmap') {
      data[[i]]$order=2
    } else if (data[[i]]$type=='barplot') {
      data[[i]]$order=3
    }
  }
  return(data)
}


draw <- function (data) {
  data <- assignOrder(data)
  
  if (length(data)>0){
    ord<-order(unlist(lapply(data, function(x){x$order})))
    data<-data[ord]
  }
  
  th = theme(legend.position = "top")
  # print(data)
  if (length(data) == 0) {
    g <- ggplot(data.frame(x = 0, y = 0, 
                           text = "No data yet, please click \"Data Upload\"")) + 
      geom_text(aes(x = x, y = y, label = text))
  } else if ((length(data) == 1) & (data[[1]]$type == 'tree')) {
    g <- draw1(data[[1]])
  } else if ((length(data) > 1) & (data[[1]]$type == 'tree')) {
    g <- draw1(data[[1]])
    row.order = get_taxa_order(g) # from top to bottom
    for (i in 2:length(data)) {
      data[[i]]$data$Label = factor(data[[i]]$data$Label, level = rev(row.order))
      g2 <- draw1(data[[i]])
      g2 <-
        g2 + theme(axis.title.y = element_blank(), axis.text.y = element_blank())
      g <- g + g2 * th
    }
  } else if (data[[1]]$type != 'tree'){
    g <- ggplot(data.frame(x = 0, y = 0,
                           text = "Please upload tree data first")) + 
      geom_text(aes(x = x, y = y, label = text))
  }
  g
}

if (T) {
  testDraw <- function() {
    # setwd("~/Downloads/Jennifer/")
    d = list(
      list(type = 'tree', data = read.tree("tree.nwk")),
      list(type = 'heatmap', data = read.csv("heatmap.csv")),
      list(type = 'barplot', data = read.csv('bar.csv'))
    )
    draw(d[1:3])
  }
  testDraw()

}
