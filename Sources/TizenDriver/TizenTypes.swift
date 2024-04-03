//
//  TizenTypes.swift
//
//
//  Created by Jan Verrept on 26/03/2022.
//

import Foundation

public enum PowerState:Comparable{
	
	case poweredOff
	case poweringDown
	case poweringUp
	case poweredOn
	
}

enum ConnectionState:Comparable{
	
	case disconnected
	case disconnecting
	case connecting
	case connected
	case paired
	
}


