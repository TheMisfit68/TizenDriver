import Foundation
import Awake
import JVCocoa

open class TizenDriver:WebSocketDelegate, Securable{
	
	// MARK: - Setup
	public let tvName:String
	let macAddress:String
	let ipAddress:String
	let port:Int
	let deviceName:String
	var deviceToken:Int!
	var pairingInfo:[String:[String:Int]] = [:]
	var commandQueue = Queue<TizenDriver.Command>()
	
	var powerStateReChecker:Timer!
	
	var installedApps:[AppInfo]?
	var appRunning:Bool?
	
	private let keyChainItem:KeyChainItem
	private let reachabilityPinger:Pinger = Pinger()

	
	open var tvIsReachable:Bool{
		
		get{
			let isReachable = self.reachabilityPinger.ping(ipAddress, timeOut: 1.0, maxResponsTime: 1.0)
			if !isReachable{
				
				if tvName == "T.V."{
					print("🐞🐞🐞🐞 T.V. -NOT- reachable") // TODO: - remove after testing
				}
				self.commandQueue = Queue<TizenDriver.Command>()
				self.connectionState = .disconnected
				self.powerState = .poweredOff
				
				
			}else{
				
				if tvName == "T.V."{
					print("🐞🐞🐞🐞 T.V. is reachable") // TODO: - remove after testing
				}
				
			}
			return isReachable
		}
		
	}
	
	open var powerState:PowerState?{
		
		// Prepare for .poweredOn or .poweredOff
		willSet{
			
			if newValue != powerState{
				
				switch newValue {
						
					case .poweringUp:
						
						if tvName == "T.V."{
							print("🐞🐞🐞🐞 T.V. powering up") // TODO: - remove after testing
						}
						
						guard tvIsReachable else{
							// Perform a WakeOnLan to make the TV reachable
							let tv = Awake.Device(MAC: macAddress, BroadcastAddr: "255.255.255.255", Port: 9)
							_ = Awake.target(device: tv)
							
							self.reCheckPowerState()
							
							return
						}
						
						self.powerState = .poweredOn
						
						
					case .poweringDown:
						
						if tvName == "T.V."{
							print("🐞🐞🐞🐞 T.V. powering down") // TODO: - remove after testing
						}
						
						guard !tvIsReachable else{
							
							if connectionState == .paired {
								send(command: .KEY(.POWER))
							}
							
							self.reCheckPowerState()
							
							return
						}
						
						self.powerState = .poweredOff
						
					default: break
				}
			}
		}
		
		didSet{
			
			if powerState != oldValue{
				
				switch powerState{
					case .poweredOn:
						if tvName == "T.V."{
							print("🐞🐞🐞🐞 T.V. is powered on") // TODO: - remove after testing
						}
						Debugger.shared.log(debugLevel: .Native(logType: .info), "'\(tvName.capitalized)' powered on 🔲")
					case .poweredOff:
						if tvName == "T.V."{
							print("🐞🐞🐞🐞 T.V. is powered off") // TODO: - remove after testing
						}
						Debugger.shared.log(debugLevel: .Native(logType: .info), "'\(tvName.capitalized)' powered off 🔳")
					default: break
				}
				
			}
		}
	}
	
	private func reCheckPowerState(){
		
		// Readjust powerState in a short intervals
		self.powerStateReChecker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
		
			switch self.powerState {
					
				case .poweringUp:
					if self.tvIsReachable{
						self.powerState = .poweredOn
					}
				case .poweringDown:
					if !self.tvIsReachable{
						self.powerState = .poweredOff
					}
				default:
					// powerState is already stable, no need for the timer for now
					self.powerStateReChecker.invalidate()
			}
		
		}
		self.powerStateReChecker.tolerance = powerStateReChecker.timeInterval/10.0 // Give the processor some slack with a 10% tolerance on the timeInterval

		
	}
	
	private var connectionState:ConnectionState! = nil{
		
		// Prepare for .connected or .disconnected
		willSet{
			
			if newValue != connectionState{
				
				switch newValue {
						
					case .disconnecting:
						if tvName == "T.V."{
							print("🐞🐞🐞🐞 T.V. disconnecting") // TODO: - remove after testing
						}
						
						webSocket.disconnect()
						Debugger.shared.log(debugLevel: .Native(logType: .info), "\(deviceName.capitalized) disconnecting from '\(tvName)' ")
						
					case .connecting:
						if tvName == "T.V."{
							print("🐞🐞🐞🐞 T.V. connecting") // TODO: - remove after testing
						}
						
						guard powerState == .poweredOn else {
							powerState = .poweringUp
							return
						}
						
						webSocket.connect()
						Debugger.shared.log(debugLevel: .Native(logType: .info), "\(deviceName.capitalized) connecting to '\(tvName)' ")
						
					default: break
						
				}
			}
			
		}
		
		didSet{
			
			switch connectionState {
					
				case .paired:
					
					if connectionState != oldValue{
						if let token = self.deviceToken{
							Debugger.shared.log(debugLevel: .Succes, "\(deviceName.capitalized) paired with '\(tvName)' using key \(token)")
						}
						getAppList()
					}
					
				case .connected:
					Debugger.shared.log(debugLevel: .Native(logType: .info), "\(deviceName.capitalized) connected with '\(tvName)'")
				case .disconnected:
					Debugger.shared.log(debugLevel: .Native(logType: .info), "\(deviceName.capitalized) disconnected from '\(tvName)'")
				default: break
			}
		}
	}
	
	private lazy var webSocket:WebSocket = {
		return newWebSocket
	}()
	
	private var newWebSocket:WebSocket{
		
		let base64DeviceName = Data(deviceName.utf8).base64EncodedString()
		print("🐞🐞🐞🐞 \(deviceName)") // TODO: - remove after testing
		let connectionString = "wss://\(ipAddress):\(port)/api/v2/channels/samsung.remote.control?name=\(base64DeviceName)&token=\(deviceToken ?? 0)"
		print("🐞🐞🐞🐞 \(connectionString)") // TODO: - remove after testing
		Debugger.shared.log(debugLevel: .Native(logType: .info), "Connectionstring:\n\(connectionString)")
		var urlRequest =  URLRequest(url: URL(string: connectionString)!)
		urlRequest.timeoutInterval = 5
		return WebSocket(urlRequest: urlRequest, delegate: self)
		
	}
	
	public init(tvName:String, macAddress:String, ipAddress:String, port:Int = 8002, deviceName:String){
		
		self.tvName = tvName
		self.macAddress = macAddress
		self.ipAddress = ipAddress
		self.port = port
		self.deviceName = deviceName
		self.keyChainItem = KeyChainItem(
			withTag:"Tizen.pairingInfo",
			kind: "Connection-token for websocket",
			account:  self.deviceName,
			location: self.tvName,
			comment: "Unique token-number for each device connecting to the TV\n(Gets regenerated with each connection that is without a valid token)"
		)
				
		if let deviceToken = valueFromKeyChain(item: keyChainItem){
			Debugger.shared.log(debugLevel: .Native(logType: .info),"Token: \(deviceToken) from keychain for \(tvName)")
			self.deviceToken = Int(deviceToken)
			self.pairingInfo = [self.tvName:[self.deviceName:self.deviceToken]]
		}
	}
	
	deinit {
		connectionState = .disconnecting
		powerState = .poweringDown
	}
	
	// MARK: - Public API
	
	public func powerOn(){
		if (powerState != .poweredOn) && (powerState != .poweringUp){
			self.powerState = .poweringUp
		}
	}
	
	public func powerOff(){
		if (powerState != .poweredOff) && (powerState != .poweringDown){
			self.powerState = .poweringDown
		}
	}
	
	public func cycleTroughChannels(_ numberOfChannels:Int = 10){
		gotoChannel(1)
		for _ in 1...numberOfChannels{
			commandQueue.enqueue(.KEY(.CHUP))
			sleep(3)
		}
	}
	
	public func gotoChannel(_ channelNumber:Int){
		quitRunningApps()
		if let numberKey = Key(rawValue:String(channelNumber)){
			commandQueue.enqueue( .KEY(numberKey), .KEY(.ENTER) )
		}
	}
	
	public func getAppList(){
		commandQueue.enqueue(.LISTAPPS)
	}
	
	public func openApp(_ app:App){
		
		if let installedApps = self.installedApps, installedApps.contains(where: {$0.id == app} ) {
			quitRunningApps()
			commandQueue.enqueue(.APP(app))
			appRunning = true
		}else{
			Debugger.shared.log(debugLevel: .Native(logType: .error), "App \(app) not installed on '\(tvName)'")
		}
		
	}
	
	public func quitRunningApps(){
		if appRunning == true{
			commandQueue.enqueue(.KEY(.EXIT)) // = Long pressed KEY_BACK
			appRunning =  false
		}
	}
	
	public func openURL(_ httpString:String){
		quitRunningApps()
		commandQueue.enqueue(.URL(httpString))
		appRunning = true
	}
	
	public func runQueue(){
		
		guard (connectionState == .paired) else{
			connectionState = .connecting
			return
		}
		
		while !commandQueue.isEmpty{
			let commandToSend = commandQueue.dequeue()!
			send(command: commandToSend)
			sleep(1)
		}
		
		webSocket.ping()
	}
	
	private func send(command:Command){
		
		var commandString:String
		
		switch command{
			case .KEY(let Key):
				commandString = """
 {
 "method": "ms.remote.control",
 "params": {
 "Cmd": "Click",
 "DataOfCmd": "KEY_\(Key.rawValue)",
 "Option": "false",
 "TypeOfRemote": "SendRemoteKey"
 }
 }
 """
				
			case .LISTAPPS:
				commandString = """
{
"method":"ms.channel.emit",
"params":{
"event": "ed.installedApp.get",
"to":"host"
}
}
"""
			case .APP(let App):
				commandString = """
   {
"method": "ms.channel.emit",
"params": {
  "event": "ed.apps.launch",
 "to": "host",
 "data": {
   "appId": "\(App.rawValue)",
   "action_type": "DEEP_LINK"
}
}
}
"""
			case .URL(let httpString):
				var metaTagSuffix = ""
				if !httpString.isEmpty{
					metaTagSuffix = """
 ,"metaTag":"\(httpString)"
 """
				}
				
				commandString = """
{"method":"ms.channel.emit",
"params":{"event": "ed.apps.launch",
"to":"host",
"data":{"appId":"org.tizen.browser",
"action_type":"NATIVE_LAUNCH"
\(metaTagSuffix)
}
}
}
"""
				
		}
		webSocket.send(text:commandString)
	}
	
	// MARK: - Connection lifecycle
	
	public func connected() {
		if tvName == "T.V."{
			print("🐞🐞🐞🐞 connected") // TODO: - remove after testing
		}
		Debugger.shared.log(debugLevel: .Event, "\(deviceName.capitalized) connected with '\(tvName)'")
		connectionState = .connected
	}
	
	public func disconnected(error: Error?) {
		Debugger.shared.log(debugLevel: .Event, "\(deviceName.capitalized) disconnected from '\(tvName)'")
		
		if (connectionState > .disconnecting){
			reconnect()
		}else{
			connectionState = .disconnected
		}
		
	}
	
	public func reconnect(){
		if tvName == "T.V."{
			print("🐞🐞🐞🐞 reconnecting") // TODO: - remove after testing
		}
		webSocket = newWebSocket
		connectionState = .connecting
	}
	
	public func received(text: String) {
		checkResultForPairingInfo(text)
		chekResultForInstalledApps(text)
	}
	
	public func received(data: Data) {
		// Not used the communication is text based
	}
	
	public func received(error: Error) {
		Debugger.shared.log(debugLevel: .Native(logType: .error), "Websocket returned error:\n\(error)")
		connectionState = .disconnected
	}
	
	private func checkResultForPairingInfo(_ result:String){
		
		if result.contains("token"){
			
			let regexPattern = "\"token\"\\s?:\\s?\"(\\d{8})\""
			if let tokenString = result.matchesAndGroups(withRegex: regexPattern).last?.last, let newToken = Int(tokenString){
				
				Debugger.shared.log(debugLevel: .Native(logType: .info), "Token:\(tokenString) returned")
				
				if newToken != self.deviceToken{
					
					if storeInKeyChain(value: tokenString, item: keyChainItem){
						// Try to connect all over again with the new token in place
						self.deviceToken = newToken
						self.connectionState = .connecting
						// Store the pairing of this TV for reuse
						self.pairingInfo = [self.tvName:[self.deviceName:self.deviceToken]]
					}
					
				}else{
					// All is perfect
					connectionState = .paired
				}
				
				
			}
		}
	}
	
	private func chekResultForInstalledApps(_ result:String){
		
		let jsonData = result.data(using: .utf8)!
		if let appInfo = try? newJSONDecoder().decode(AppsRootData.self, from: jsonData){
			self.installedApps = appInfo.data.data
		}
		
	}
	
	
}

