<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl xsi:schemaLocation="http://www.ncl.org.br/NCL3.0/EDTVProfile http://www.ncl.org.br/NCL3.0/profiles/NCL30EDTV.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile" id="defaultNCL">

<head>

 <transitionBase>
        <transition id="trans1" type="fade" dur="0.1s"/>
        <transition id="trans2" type="fade" dur="0.1s"/>
    </transitionBase>
    <regionBase>
        <region id="regionVideo" left="0"  top="0"  width="1280"  height="720"  zIndex="1"/>
        <region id="regionApplication" left="0"  top="0" width="1280"  height="720" zIndex="1"/>
    </regionBase>

    <descriptorBase>
        <descriptor id="descriptorApplication" region="regionApplication" focusIndex="application" focusBorderWidth="0" focusBorderColor="black" selBorderColor="black" focusBorderTransparency="100%"/>
        <descriptor id="descriptorVideo" region="regionVideo" focusBorderWidth="0" focusBorderColor="black" selBorderColor="black" focusBorderTransparency="100%" transIn="trans1" transOut="trans2"/>
    </descriptorBase>

    <connectorBase>
        <causalConnector id="onBeginAttributionSet_var">
            <connectorParam name="var"/>
            <simpleCondition role="onBeginAttribution"/>
            <simpleAction role="set" value="$var"/>
        </causalConnector>

        <causalConnector id="onEndAttributionSet">
            <connectorParam name="valueSet" />
            <simpleCondition role="onEndAttribution" max="unbounded" qualifier="or"/>
            <compoundAction operator="seq">
                <simpleAction role="pause"/>
                <simpleAction role="set" max="unbounded" qualifier="seq" value="$valueSet"/>
                <simpleAction role="resume"/>
            </compoundAction>
        </causalConnector>

        <causalConnector id="onEndAttributionStart">
          <simpleCondition role="onEndAttribution"/>
          <simpleAction role="start" max="unbounded"/>
        </causalConnector>


        <causalConnector id="onBeginSet">
            <connectorParam name="var"/>
            <simpleCondition role="onBegin"/>
            <simpleAction role="set" value="$var"/>
        </causalConnector>
        <causalConnector id="onKeySelectionSet_var">
            <connectorParam name="keyCode"/>
            <connectorParam name="var"/>
            <simpleCondition role="onSelection" key="$keyCode"/>
            <simpleAction role="set" value="$var"/>
        </causalConnector>
    </connectorBase>

</head>

<body>
    <port id="portVideo" component="video"/>
    <port id="portApplication" component="application"/>
    <media id="video" src="sbtvd-ts://video" descriptor="descriptorVideo"> 
        <property name="bounds"/>
    </media>
    <media id="application" src="main.lua" descriptor="descriptorApplication">
        <property name="keyBack"/>
        <property name="downsize"/>
        <property name="upsize"/>
        <property name="language"/>
        <property name="caption"/>
        <property name="subtitle"/>
        <property name="screenSize"/>
        <property name="screenGraphicSize"/>
        <property name="audioType"/>
        <property name="classNumber"/>
        <property name="CPU"/>
        <property name="memory"/>
        <property name="operatingSystem"/>
        <property name="javaConfiguration"/>
        <property name="javaProfile"/>
        <property name="luaVersion"/>
        <property name="lua_version"/>
        <property name="ncl_version"/>
        <property name="nclversion"/>
        <property name="GingaNCL_version"/>
        <property name="GingaJ_version"/>
        <property name="gingaNCLProfile"/>
        <!-- <property name="persistent"/> -->
        <property name="makerId"/>
        <property name="modelId"/>
        <property name="versionId"/>
        <property name="serialNumber"/>
        <property name="macAddress"/>
        <property name="luaSupportedEventClasses"/>
        <property name="hasActiveNetwork"/>
        <property name="hasNetworkConnectivity"/>
        <property name="maxNetworkBitRate"/>
        <property name="age"/>
        <property name="location"/>
        <property name="genre"/>
        <property name="name"/>
        <property name="focusBorderColor"/>
        <property name="currentKeyMaster"/>
        <property name="numberOfServices"/>
        <property name="numberOfPartialServices"/>
        <property name="channeNumber"/>
        <property name="keyCapture"/>
    </media>      

	<media type="application/x-ginga-settings" id="settings">
        <property name="service.currentKeyMaster" value="application"/>
        <property name="system.language"/>
        <property name="system.caption"/>
        <property name="system.subtitle"/>
        <property name="system.screenSize"/>
        <property name="system.screenGraphicSize"/>
        <property name="system.audioType"/>
        <property name="system.classNumber"/>
        <property name="system.CPU"/>
        <property name="system.memory"/>
        <property name="system.operatingSystem"/>
        <property name="system.javaConfiguration"/>
        <property name="system.javaProfile"/>
        <property name="system.luaVersion"/>
        <property name="system.lua.version"/>
        <property name="system.ncl.version"/>
        <property name="system.nclversion"/>
        <property name="system.GingaNCL.version"/>
        <property name="system.GingaJ.version"/>
        <property name="system.gingaNCLProfile"/>
        <!-- <property name="system.persistent"/> -->
        <property name="system.makerId"/>
        <property name="system.modelId"/>
        <property name="system.versionId"/>
        <property name="system.serialNumber"/>
        <property name="system.macAddress"/>
        <property name="system.luaSupportedEventClasses"/>
        <property name="system.hasActiveNetwork"/>
        <property name="system.hasNetworkConnectivity"/>
        <property name="system.maxNetworkBitRate"/>
        <property name="user.age"/>
        <property name="user.location"/>
        <property name="user.genre"/>
        <property name="user.name"/>
        <property name="default.focusBorderColor"/>
        <property name="si.numberOfServices"/>
        <property name="si.numberOfPartialServices"/>
        <property name="si.channeNumber"/>
        <property name="channel.keyCapture"/>
	</media>

    <!-- Resize -->
        <link id="linkDownsize" xconnector="onEndAttributionSet">			
            <bind component="application" interface="downsize" role="onEndAttribution"/>
            <bind role="pause" component="video"/>
            <bind component="video" role="set" interface="bounds">
				<bindParam name="valueSet" value="0, 0, 1024, 576"/> 
            </bind>
            <bind role="resume" component="video"/>
        </link>
        <link id="linkUpsize" xconnector="onEndAttributionSet">			
            <bind component="application" interface="upsize" role="onEndAttribution"/>
            <bind role="pause" component="video"/>
            <bind component="video" role="set" interface="bounds">
                <bindParam name="valueSet" value="0, 0, 1280, 720"/>
            </bind>
            <bind role="resume" component="video"/>
        </link>


    <!-- Application focus -->
        <link xconnector="onBeginSet">
            <bind role="onBegin" component="application"/>
            <bind role="set" component="settings" interface="service.currentKeyMaster">
                <bindParam name="var" value="application"/>
            </bind>
        </link>
        
        <link id="KeyBackPressed" xconnector="onKeySelectionSet_var">
			<bind component="application" role="onSelection">
				<bindParam name="keyCode" value="BACK" />
			</bind>
			<bind component="settings" interface="service.currentKeyMaster" role="set">
				<bindParam name="var" value="application"/>
			</bind>  	 			
            <bind component="application" interface="keyBack" role="set">
				<bindParam name="var" value="1"/>
			</bind>  	
		</link>

    <!-- Settings -->
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="language">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.language"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="caption">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.caption"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="subtitle">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.subtitle"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="screenSize">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.screenSize"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="screenGraphicSize">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.screenGraphicSize"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="audioType">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.audioType"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="classNumber">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.classNumber"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="CPU">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.CPU"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="memory">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.memory"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="operatingSystem">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.operatingSystem"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="javaConfiguration">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.javaConfiguration"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="javaProfile">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.javaProfile"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="luaVersion">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.luaVersion"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="lua_version">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.lua.version"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="ncl_version">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.ncl.version"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="nclversion">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.nclversion"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="GingaNCL_version">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.GingaNCL.version"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="GingaJ_version">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.GingaJ.version"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="gingaNCLProfile">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.gingaNCLProfile"/>
		</link>
    
		<!-- <link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="persistent">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.persistent"/>
		</link>
     -->
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="makerId">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.makerId"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="modelId">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.modelId"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="versionId">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.versionId"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="serialNumber">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.serialNumber"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="macAddress">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.macAddress"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="luaSupportedEventClasses">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.luaSupportedEventClasses"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="hasActiveNetwork">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.hasActiveNetwork"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="hasNetworkConnectivity">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.hasNetworkConnectivity"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="maxNetworkBitRate">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="system.maxNetworkBitRate"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="age">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="user.age"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="location">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="user.location"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="genre">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="user.genre"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="name">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="user.name"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="focusBorderColor">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="default.focusBorderColor"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="currentKeyMaster">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="service.currentKeyMaster"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="numberOfServices">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="si.numberOfServices"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="numberOfPartialServices">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="si.numberOfPartialServices"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="channeNumber">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="si.channeNumber"/>
		</link>
    
		<link xconnector="onBeginSet">
			<bind role="onBegin" component="application"/>
			<bind role="set" component="application" interface="keyCapture">
				<bindParam name="var" value="$get"/>
			</bind>
			<bind role="get" component="settings" interface="channel.keyCapture"/>
		</link>
    
    <!-- End of Settings -->
</body>
</ncl>
