//
//  TizenCommands.swift
//
//
//  Created by Jan Verrept on 28/02/2020.
//

import Foundation

public extension TizenDriver{
	
	enum Command{
		
		case KEY(TizenDriver.Key)
		case LISTAPPS
		case APP(TizenDriver.App)
		case URL(String)
		
	}
	
	enum Key:String {
		
		case POWER
		case UP
		case DOWN
		case LEFT
		case RIGHT
		case CHUP
		case CHDOWN
		case PRECH
		case ENTER
		case RETURN
		case EXIT
		case CONTENTS
		case CH_LIST
		case MENU
		case SOURCE
		case GUIDE
		case TOOLS
		case INFO
		case RED
		case GREEN
		case YELLOW
		case BLUE
		case PANNEL_CHDOWN
		case VOLUP
		case VOLDOWN
		case MUTE
		case DTV
		case HDMI
		case DTV_LINK
		case EXT5
		case EMANUAL
		case SEARCH
		case CAPTION
		case NUMBER_0 = "0"
		case NUMBER_1 = "1"
		case NUMBER_2 = "2"
		case NUMBER_3 = "3"
		case NUMBER_4 = "4"
		case NUMBER_5 = "5"
		case NUMBER_6 = "6"
		case NUMBER_7 = "7"
		case NUMBER_8 = "8"
		case NUMBER_9 = "9"
		
	}
	
	enum App:String {
		
		case Internet = "org.tizen.browser"
		case Streamz = "3201911019691"
		case SmartIPTV = "111477001080"
		case meJane = "111399000073"
		case YouTube = "111299001912"
		case e_Manual = "20172100006"
		case Netflix = "11101200001"
		case LoveNature4K = "3201703012065"
		case VisitGreece = "111477001142"
		case GooglePlayFilmsTV = "3201601007250"
		case OttPlayer = "3201503001595"
		case TVVLAANDEREN = "3201804016164"
		case ElevenBelgium = "3201612011395"
		case Deezer = "3201608010191"
		case GameFlyStreaming = "3201504002064"
		case Plex = "3201512006963"
		case SteamLink = "3201702011851"
		case EurosportPlayer = "3201703012079"
		case RakutenTV = "3201511006428"
		case PrimeVideo = "3201512006785"
		case Spotify = "3201606009684"
		case RedBullTV = "3201602007756"
		case FacebookWatch = "11091000000"
		case McAfeeSecurityForTV = "3201612011418"
		case TÉLÉSAT = "3201804016076"
		case PrivacyChoices = "3201909019271"
		case DisneyPlus = "3201901017640"
		case VTMGO = "3202102022902"
		
		case All4 = "111299002148"
		case AppleTV = "3201807016597"
		case BBCnews = "3201602007865"
		case BBCsport = "3201602007866"
		case BBCiPlayer = "3201601007670"
		case BTsport = "3201811017267"
		case CHILI = "3201505002690"
		case Gallery = "3201710015037"
		case HBOgo = "3201706012478"
		case ITVhub = "121299000089"
		case My5 = "121299000612"
		case NOWTV = "3201603008746"
		case SmartThings = "3201710015016"
		case UniversalGuide = "3201710015067"
		case hayu = "3201806016381"
	}
	
}
