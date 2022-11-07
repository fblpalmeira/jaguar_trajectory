#Jaguar Datapaper
y1 <- read.csv("jaguar_movement_data.csv", header=T, sep=",")
View(y1)

library (readxl)
y2 <- read_excel("Jaguar_additional information.xlsx", na = "-")
View(y2)

library(dplyr)
y1 <- y1 %>%
  rename(ID = "individual.local.identifier..ID.",
         lon = "location.long",
         lat = "location.lat",
         tag = "tag.local.identifier") 
y2 <- y2 %>%
  rename(Age = "Estimated Age") 

y3 = merge(y1, y2, by="ID", all.x=F)
View(y3)

y4<- filter(y3, study.name=="Jaguar_Taiama")
View(y4)

move_felid<- filter(y4, tag=="36312")
View(move_felid)

#Ajuste da leitura da data/hora
move_felid$timestamp <-as.POSIXct(strptime(move_felid$timestamp, "%m/%d/%y %H:%M", tz ="GMT"))


# abre os pacotes
library (move)
library (moveVis)
library (magrittr)
library (ggplot2)

library (maptools) # utilizacao de shapefiles

# reconhece a projecao, define as colunas dos individuos, do tempo e das coordenadas
m <-df2move(move_felid,
            proj=CRS("+proj=longlat +ellps=GRS80"),
            x = "lon", y = "lat", time = "timestamp", track_id = "tag")

# define a resolucao de tempo por frame em segundos (res=4320 significa que cada frame tem 12 horas de amostragem)
# quanto menor a resolucao sera mais detalhado a visualizacao do movimento, 
# mas aumenta muito o tempo para carregar o gif (as vezes ? necessario utilizar outros formatos de v?deo para salvar o arquivo)e o aumenta o tamanho do arquivo
# para este banco de dados 1 frame = 12 horas demora ~26 minutos com um processador i7 2.10GHz, 8GB Ram, .
# resolution of 1 day (86400seconds) at digit 0 (:00 seconds) per timestamp:

am <- align_move(m, res = 43200, digit = 0, unit = "secs")
unique(unlist(timeLag(am, units = "secs")))

# opcoes de mapas para imagens de satelite necessario tem o token do mapbox. usar o map_service="osm"
get_maptypes()

# imagem de satelite
frames <- frames_spatial(am, path_colours = c("#E69F00"),path_legend = T, path_legend_title = "Jaguar ID",
                         map_service = "osm", map_type ="topographic",trace_show = T, 
                         tail_colour = "#E69F00",trace_colour = "#E69F00", tail_size = 0.8,equidistant = T, map_res=1) %>% 
 

  # adiciona informaces aos frames, como os eixos das coordenadas, titulos, subtitulos, escala, norte.
  add_labels(x = "Longitude", y = "Latitude", title="Trajectory of a female jaguar the in Brazilian wetlands" , subtitle="Jaguar movement database: a GPS-based movement dataset <doi.org/10.1002/ecy.2379>") %>% 
  add_timestamps(am, type = "label") %>% 
  add_progress()

# informar um texto sobre os frames (nesse caso o nome de quem criou a animacao). verificar as coordenadas para inserir corretamente a informacao.
frames <- add_text(frames, "@fblpalmeira", x = -57.43, y = -17.26,
                   colour = "grey", size = 2.8)

# visualiza um frame para verificar se esta certo antes de carregar o gif
frames[[270]]

# sugere formatos diferentes para salvar o arquivo
# suggest_formats()

# define, tamanho, resolucao, nome do arquivo e local onde ser salvo o gif 
# certifique-se do caminho do diretorio, se errar a pasta vai  ter que carregar de novo)
png(file = "Jaguar_Taiama_Tag36312_female.gif", width = 600, height = 600)
animate_frames(frames, out_file = "D:/Francesca/Documents/R/MapChallenge/Jaguar_Taiama_Tag36312_female.gif", width = 800, height = 550, res = 95)
dev.off()
