    script_name("MVDHelper")
    script_version("v3")

    local imgui = require 'mimgui'
    local encoding = require 'encoding'
    encoding.default = 'CP1251'
    local u8 = encoding.UTF8
    local new = imgui.new
    local ffi = require 'ffi'
    local ev = require 'samp.events'
    local new, str = imgui.new, ffi.string
    local socket_url = require'socket.url'
    local vkeys = require 'vkeys'
    local hotkey = require 'mimgui_hotkeys'
    local faicons = require("fAwesome6")
    local ini = require 'inicfg'

    local enable_autoupdate = true
    local autoupdate_loaded = false
    local Update = nil
    if enable_autoupdate then
        local updater_loaded, Updater = pcall(loadstring, u8:decode[[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
        if updater_loaded then
            autoupdate_loaded, Update = pcall(Updater)
            if autoupdate_loaded then
                Update.json_url = "https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/MVDHelper.json?" .. tostring(os.clock())
                Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
                Update.url = "https://github.com/Andergr0ynd/MVDHelper/tree/main"
            end
        end
    end

    local settings = ini.load({
         player = {
         username = '',
         tag = '',
         rang = '',
         otdel = '',
         krit = '',
        },
        hotkey_cfg = {
            bind = '[18,51]',
            bind2 = '[]',
            bind3 = '[]',
            bind4 = '[]',
            bind5 = '[]',
        },
        slider_settings = {
            slider_msm = 5,
            slider_notification = 5,
            slider_text = 5,
        },
        volume_settings = {
            volume = 1,
            music = false,
        },
        color = {
            theme = '1',
        },
        command_enabling = {
            msm_enabling = true,
            mdoc_enabling = true,
            mdoc2_enabling = true,
            mdoc3_enabling = true,
            mdoc4_enabling = true,
            mdoc5_enabling = true,
            mdoc6_enabling = true,
            omondoc_enabling = true,
            mcuff_enabling = true,
            muncuff_enabling = true,
            mclear_enabling = true,
            marrest_enabling = true,
            msu_enabling = true,
            mpg_enabling = true,
            mtakelic_enabling = true,
            mticket_enabling = true,
            mputpl_enabling = true,
            miranda_enabling = true,
            photo_enabling = true,
            mcheckdocs_enabling = true,
            mejectout_enabling = true,
            msearch_enabling = true,
            mattach_enabling = true,
        },
    }, 'MVDHelper.ini')

    local enabling_msm = new.bool(settings.command_enabling.msm_enabling)
    local enabling_mdoc = new.bool(settings.command_enabling.mdoc_enabling)
    local enabling_mdoc2 = new.bool(settings.command_enabling.mdoc2_enabling)
    local enabling_mdoc3 = new.bool(settings.command_enabling.mdoc3_enabling)
    local enabling_mdoc4 = new.bool(settings.command_enabling.mdoc4_enabling)
    local enabling_mdoc5 = new.bool(settings.command_enabling.mdoc5_enabling)
    local enabling_mdoc6 = new.bool(settings.command_enabling.mdoc6_enabling)
    local enabling_omondoc = new.bool(settings.command_enabling.omondoc_enabling)
    local enabling_mcuff = new.bool(settings.command_enabling.mcuff_enabling)
    local enabling_muncuff = new.bool(settings.command_enabling.muncuff_enabling)
    local enabling_mclear = new.bool(settings.command_enabling.mclear_enabling)
    local enabling_marrest = new.bool(settings.command_enabling.marrest_enabling)
    local enabling_msu = new.bool(settings.command_enabling.msu_enabling)
    local enabling_mpg = new.bool(settings.command_enabling.mpg_enabling)
    local enabling_mtakelic = new.bool(settings.command_enabling.mtakelic_enabling)
    local enabling_mticket = new.bool(settings.command_enabling.mticket_enabling)
    local enabling_mputpl = new.bool(settings.command_enabling.mputpl_enabling)
    local enabling_miranda = new.bool(settings.command_enabling.miranda_enabling)
    local enabling_photo = new.bool(settings.command_enabling.photo_enabling)
    local enabling_mcheckdocs = new.bool(settings.command_enabling.mcheckdocs_enabling)
    local enabling_mejectout = new.bool(settings.command_enabling.mejectout_enabling)
    local enabling_msearch = new.bool(settings.command_enabling.msearch_enabling)
    local enabling_mattach = new.bool(settings.command_enabling.mattach_enabling)

    local tab = 1
    local MenuMVD = new.bool()
    local MenuFunction = new.bool()
    local MenuKoap = new.bool()
    local MenuLeader = new.bool()

    local inputField = new.char[256]()

    local HotkeyCFGMenuMVD
    local HotkeyCFGFunction
    local HotkeyCFGKoap
    local HotkeyCFGMsm
    local HotkeyCFGLeader
    local sw, sh = getScreenResolution()
    local mainWindow = imgui.new.bool(true)

    local InputUsername = new.char[256](u8(settings.player.username))
    local InputTag = new.char[256](u8(settings.player.tag))
    local InputRang = new.char[256](u8(settings.player.rang))
    local InputOtdel = new.char[256](u8(settings.player.otdel))
    local InputKrit = new.char[256](u8(settings.player.krit))

    local slider_msm = imgui.new.int(settings.slider_settings.slider_msm)
    local slider_notification = imgui.new.int(settings.slider_settings.slider_notification)
    local slider_text = imgui.new.int(settings.slider_settings.slider_text)
    local sliderBuf = new.int()

    local music_settings = new.bool(settings.volume_settings.music)
    local volume_settings = imgui.new.int(settings.volume_settings.volume)
    local as_action = require('moonloader').audiostream_state
    local sound_streams = {}
    local sounds = {
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest1.mp3',
        file_name = 'arrest1.mp3',
    },
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest2.mp3',
        file_name = 'arrest2.mp3',
    },
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest3.mp3',
        file_name = 'arrest3.mp3',
    },
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest4.mp3',
        file_name = 'arrest4.mp3',
    },
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest5.mp3',
        file_name = 'arrest5.mp3',
    },
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest6.mp3',
        file_name = 'arrest6.mp3',
    },
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest7.mp3',
        file_name = 'arrest7.mp3',
    },
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest8.mp3',
        file_name = 'arrest8.mp3',
    },
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest9.mp3',
        file_name = 'arrest9.mp3',
    },
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest10.mp3',
        file_name = 'arrest10.mp3',
    },
    {
        url = 'https://github.com/Andergr0ynd/MVDHelper/raw/refs/heads/main/sounds/arrest11.mp3',
        file_name = 'arrest11.mp3',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap01.txt',
        file_name = 'koap01.txt',
    },
        {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap02.txt',
        file_name = 'koap02.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap03.txt',
        file_name = 'koap03.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap04.txt',
        file_name = 'koap04.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap05.txt',
        file_name = 'koap05.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap06.txt',
        file_name = 'koap06.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap07.txt',
        file_name = 'koap07.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap08.txt',
        file_name = 'koap08.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap09.txt',
        file_name = 'koap09.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap10.txt',
        file_name = 'koap10.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap11.txt',
        file_name = 'koap11.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap12.txt',
        file_name = 'koap12.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap13.txt',
        file_name = 'koap13.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap14.txt',
        file_name = 'koap14.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap15.txt',
        file_name = 'koap15.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap16.txt',
        file_name = 'koap16.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap17.txt',
        file_name = 'koap17.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap18.txt',
        file_name = 'koap18.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap19.txt',
        file_name = 'koap19.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap20.txt',
        file_name = 'koap20.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap21.txt',
        file_name = 'koap21.txt',
    },
    {
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/logo.png',
        file_name = 'logo.png',
    },
}

    local notifyPool = {}
    local duration = 15
    local quitReasons = {
        [0] = u8:decode"Краш / Тайм-аут",
        [1] = u8:decode"Вышел c сервера",
        [2] = u8:decode"Кикнут сервером"
    }

    local colorList = {'Красная', 'Синяя', 'Фиолетовая', 'Черная'}
    local colorListNumber = new.int(tonumber(settings.color.theme) or 0)
    local colorListBuffer = new['const char*'][#colorList](colorList)

    local msm = ''
    local activate = false
    local stop = false

    imgui.OnFrame(function() return MenuMVD[0] end, function(player)
        local X, Y = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(780, 350), imgui.Cond.Always)
        imgui.Begin(u8'MVDHelper | Settings', MenuMVD, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
        if imgui.BeginChild('Menu', imgui.ImVec2(190, 313), true) then
        imgui.Image(imhandle, imgui.ImVec2(160, 60))
        if imgui.Button(faicons('gears') .. ' Настройки', imgui.ImVec2(180, 30)) then tab = 1 end
        if imgui.Button(faicons('gears') .. ' Настройки | Отыгровки', imgui.ImVec2(180, 30)) then tab = 2 end
        if imgui.Button(faicons('keyboard') .. ' Бинды | AutoHotkey', imgui.ImVec2(180, 30)) then tab = 3 end
        if imgui.Button(faicons('eye') .. ' Вкл / Выкл', imgui.ImVec2(180, 30)) then tab = 4 end
        if imgui.Button(faicons('plus') .. ' Дополнительно', imgui.ImVec2(180, 30)) then tab = 5 end
        imgui.EndChild()
    end
        imgui.SameLine()
        if imgui.BeginChild('Function', imgui.ImVec2(580, 313), true) then
        if tab == 1 then
	    imgui.Text('Интервал для setmark | msm')
	    if imgui.SliderInt(faicons('clock') .. '', slider_msm, 1, 10) then 
	    settings.slider_settings.slider_msm = slider_msm[0]
	    ini.save(settings, 'MVDHelper.ini')
    end
	    imgui.Text('Интервал уведомлений')
	    if imgui.SliderInt(faicons('clock') .. ' ', slider_notification, 5, 10) then 
	    settings.slider_settings.slider_notification = slider_notification[0]
	    ini.save(settings, 'MVDHelper.ini')
    end
	    imgui.Text('Интервал отыгровок')
	    if imgui.SliderInt(faicons('clock') .. '  ', slider_text, 5, 15) then 
	    settings.slider_settings.slider_text = slider_text[0]
	    ini.save(settings, 'MVDHelper.ini')
    end
        imgui.Separator()
	    imgui.Text('Громкость')
	    if imgui.SliderInt(faicons('volume') .. " ##volume", volume_settings, 0, 10) then
	    if music ~= nil then setAudioStreamVolume(music, volume.v / 10) end
	    settings.volume_settings.volume = volume_settings[0]
	    ini.save(settings, 'MVDHelper.ini')
    end
	    if imgui.Button(faicons('volume') .. ' Проверка звука', imgui.ImVec2(137, 30)) then
	    playRandomSound()
    end
        if imgui.Checkbox('Включить звук', music_settings) then
        settings.volume_settings.music = music_settings[0]
        ini.save(settings, 'MVDHelper.ini')
    end
    elseif tab == 2 then
        imgui.Text('Для отыгровок')
        imgui.SetNextItemWidth(234)if imgui.InputTextWithHint('Nick_Name', 'Имя Фамилия | Позывной', InputUsername, 256) then end
	    imgui.SetNextItemWidth(234)if imgui.InputTextWithHint('Тэг', 'С', InputTag, 256) then end
        imgui.SetNextItemWidth(234)if imgui.InputTextWithHint('Звание', 'Сержант', InputRang, 256) then end
        imgui.SetNextItemWidth(234)if imgui.InputTextWithHint('Отдел', 'ДПС | ППС | ОМОН', InputOtdel, 256) then end

        imgui.Separator()
        imgui.Text('Для лидеров | замов')
        imgui.Text('Для понимания, этот текст: Критерии: 5-и летняя прописка, пакет лицензий, мед.карта и военный билет.')
        imgui.Text('Заменится на текст, который вы введете ниже')
        imgui.SetNextItemWidth(234)if imgui.InputTextWithHint('Критерии | В зависимости от сервера', 'GPS | Критерий', InputKrit, 256) then end
        settings.player.username = u8:decode(str(InputUsername))
	    settings.player.tag = u8:decode(str(InputTag))
        settings.player.rang = u8:decode(str(InputRang))
	    settings.player.otdel = u8:decode(str(InputOtdel))
	    settings.player.krit = u8:decode(str(InputKrit))
	    ini.save(settings, 'MVDHelper.ini')
    elseif tab == 3 then
        imgui.Text(faicons('unlock') .. ' Открытие настроек')
        if HotkeyCFGMenuMVD:ShowHotKey() then
        settings.hotkey_cfg.bind = encodeJson(HotkeyCFGMenuMVD:GetHotKey())
        ini.save(settings, 'MVDHelper.ini')
    end
        imgui.Text(faicons('unlock') .. ' Открытие меню')
        if HotkeyCFGFunction:ShowHotKey() then
        settings.hotkey_cfg.bind2 = encodeJson(HotkeyCFGFunction:GetHotKey())
        ini.save(settings, 'MVDHelper.ini')
    end
        imgui.Text(faicons('unlock') .. ' Открытие КоАП')
        if HotkeyCFGKoap:ShowHotKey() then
        settings.hotkey_cfg.bind3 = encodeJson(HotkeyCFGKoap:GetHotKey())
        ini.save(settings, 'MVDHelper.ini')
    end
        imgui.Text(faicons('unlock') .. ' Открытие лидерского меню')
        if HotkeyCFGLeader:ShowHotKey() then
        settings.hotkey_cfg.bind5 = encodeJson(HotkeyCFGLeader:GetHotKey())
        ini.save(settings, 'MVDHelper.ini')
    end
        imgui.Text(faicons('bell') .. ' Остановка /setmark')
        if HotkeyCFGMsm:ShowHotKey() then
        settings.hotkey_cfg.bind4 = encodeJson(HotkeyCFGMsm:GetHotKey())
        ini.save(settings, 'MVDHelper.ini')
    end
    elseif tab == 4 then
        imgui.Text('Включение | Отключение команд')

        local startX = imgui.GetCursorPosX()
        local startY = imgui.GetCursorPosY()

        local columnOffset = 200
        local rowSpacing = 17

        local items = {
            { 'Вкл | Выкл /msm', enabling_msm, 'enabling_msm' },
            { 'Вкл | Выкл /mdoc', enabling_mdoc, 'enabling_mdoc' },
            { 'Вкл | Выкл /mdoc2', enabling_mdoc2, 'enabling_mdoc' },
            { 'Вкл | Выкл /mdoc3', enabling_mdoc3, 'enabling_mdoc' },
            { 'Вкл | Выкл /mdoc4', enabling_mdoc4, 'enabling_mdoc' },
            { 'Вкл | Выкл /mdoc5', enabling_mdoc5, 'enabling_mdoc' },
            { 'Вкл | Выкл /mdoc6', enabling_mdoc6, 'enabling_mdoc' },
            { 'Вкл | Выкл /omondoc', enabling_omondoc, 'enabling_omondoc' },
            { 'Вкл | Выкл /mcuff', enabling_mcuff, 'enabling_mcuff' },
            { 'Вкл | Выкл /muncuff', enabling_muncuff, 'enabling_muncuff' },
            { 'Вкл | Выкл /mclear', enabling_mclear, 'enabling_mclear' },
            { 'Вкл | Выкл /marrest', enabling_marrest, 'enabling_marrest' },
            { 'Вкл | Выкл /msu', enabling_msu, 'enabling_msu' },
            { 'Вкл | Выкл /mpg', enabling_mpg, 'enabling_mpg' },
            { 'Вкл | Выкл /mtakelic', enabling_mtakelic, 'enabling_mtakelic' },
            { 'Вкл | Выкл /mticket', enabling_mticket, 'enabling_mticket' },
            { 'Вкл | Выкл /mputpl', enabling_mputpl, 'enabling_mputpl' },
            { 'Вкл | Выкл /miranda', enabling_miranda, 'enabling_miranda' },
            { 'Вкл | Выкл /photo', enabling_photo, 'enabling_photo' },
            { 'Вкл | Выкл /mcheckdocs', enabling_mcheckdocs, 'enabling_mcheckdocs' },
            { 'Вкл | Выкл /mejectout', enabling_mejectout, 'enabling_mejectout' },
            { 'Вкл | Выкл /msearch', enabling_msearch, 'enabling_msearch' },
            { 'Вкл | Выкл /mattach', enabling_mattach, 'enabling_mattach' }
        }
        for i, item in ipairs(items) do
            local column = (i - 1) % 2
            local row = math.floor((i - 1) / 2)
            imgui.SetCursorPosX(startX + column * columnOffset)
            imgui.SetCursorPosY(startY + row * (imgui.GetTextLineHeight() + rowSpacing))

            if imgui.Checkbox(item[1], item[2]) then
            settings.command_enabling[item[3]] = item[2][0]
            ini.save(settings, 'MVDHelper.ini')
        end
    end
    elseif tab == 5 then
        if imgui.Button(faicons('eject') .. ' Discord', imgui.ImVec2(145, 30)) then
        os.execute("start https://discord.gg/5KDB5Nww3b")
        end
        if imgui.Button(faicons('eject') .. ' Boosty', imgui.ImVec2(145, 30)) then
        os.execute("start https://boosty.to/andergr0ynd")
            end
        if imgui.Button(faicons('eject') .. 'Сайт', imgui.ImVec2(145, 30)) then
        os.execute("start https://andergr0ynd.github.io/WebsiteforAHK/global.html")
            end
        if imgui.Button(faicons('rotate') .. ' Перезагрузить AHK', imgui.ImVec2(145, 30)) then
        thisScript():reload()
            end
        if imgui.Combo(faicons('palette') .. ' Темы',colorListNumber,colorListBuffer, #colorList) then
        theme[colorListNumber[0]+1].change()
        settings.color.theme = tostring(colorListNumber[0])
        ini.save(settings, 'MVDHelper')
                end
                imgui.EndChild()
            end
            imgui.End()
        end
    end)

        imgui.OnFrame(function() return MenuLeader[0] end, function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(480, 310), imgui.Cond.Always)
        imgui.Begin('MVDHelper | Лидер', MenuLeader, imgui.WindowFlags.NoResize)
        
        if imgui.Button('Госка | Спросить', imgui.ImVec2(230, 30)) then
	    imgui.OpenPopup('Госка | Спросить')
        end
        if imgui.BeginPopupModal('Госка | Спросить', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(400, 258))
        imgui.Text('Введите время')
        imgui.InputTextWithHint('', 'Пример: 13:30', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode"[МВД] Волна государственных новостей свободна на " ..text.. "?" ,-1)
        end)
            else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел время...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end
        
        imgui.SameLine()
        if imgui.Button('Госка | Занять', imgui.ImVec2(230, 30)) then
	    imgui.OpenPopup('Госка | Занять')
        end
        if imgui.BeginPopupModal('Госка | Занять', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(400, 258))
        imgui.Text('Введите время')
        imgui.InputTextWithHint('', 'Пример: 13:30', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode"[МВД] Не услышав ответа, занимаю волну государственных новостей на " ..text.. "!" ,-1)
        end)
            else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел время...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Госка | Напомнить', imgui.ImVec2(230, 30)) then
	    imgui.OpenPopup('Госка | Напомнить')
        end
        if imgui.BeginPopupModal('Госка | Напомнить', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(400, 258))
        imgui.Text('Введите время')
        imgui.InputTextWithHint('', 'Пример: 13:30', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode"[МВД] Напоминаю, что волна государственных новостей занята на " ..text.. "!" ,-1)
        end)
            else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел время...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        imgui.SameLine()
        if imgui.Button('Начало собеседования', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        sampSendChat(u8:decode'/rr Прошу 15 секунд тишины, госка!')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/dd Прошу 15 секунд тишины, госка!')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/d [МВД] Занимаю волну государственных новостей.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/gov МВД | Уважаемые жители Нижегородской области.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/gov МВД | Сейчас пройдет собеседование в МВД. в г.Арзамас')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/gov МВД | '..settings.player.krit..'')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/d [МВД] Освобождаю волну государственных новостей.')
        wait(slider_text[0] * 100)
        sampSendChat('/c 060')
        wait(slider_text[0] * 100)
        setVirtualKeyDown(119, true)
        wait(slider_text[0] * 100)
        setVirtualKeyDown(119, false)
            end)
        end

        if imgui.Button('Продолжение собеседования', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        sampSendChat(u8:decode'/rr Прошу 15 секунд тишины, госка!')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/dd Прошу 15 секунд тишины, госка!')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/d [МВД] Занимаю волну государственных новостей.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/gov МВД | Собеседование в МВД продолжается.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/d [МВД] Освобождаю волну государственных новостей.')
        wait(slider_text[0] * 100)
        sampSendChat('/c 060')
        wait(slider_text[0] * 100)
        setVirtualKeyDown(119, true)
        wait(slider_text[0] * 100)
        setVirtualKeyDown(119, false)
            end)
        end

        imgui.SameLine()
        if imgui.Button('Конец собеседования', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        sampSendChat(u8:decode'/rr Прошу 15 секунд тишины, госка!')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/dd Прошу 15 секунд тишины, госка!')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/d [МВД] Занимаю волну государственных новостей.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/gov МВД | Уважаемые жители Нижегородской области.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/gov МВД | Собеседование в МВД окончено.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/gov МВД | Спасибо за внимание, с уважением Генерал - '..settings.player.username..'.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/d [МВД] Освобождаю волну государственных новостей.')
        wait(slider_text[0] * 100)
        sampSendChat('/c 060')
        wait(slider_text[0] * 100)
        setVirtualKeyDown(119, true)
        wait(slider_text[0] * 100)
        setVirtualKeyDown(119, false)
            end)
        end

        if imgui.Button('Собрать на строй', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        sampSendChat(u8:decode'/r ['..settings.player.tag..'] Строй на плацу! Готовность 5 минут! Кого нет - выговор.')
            end)
        end

        imgui.SameLine()
        if imgui.Button('Вы на собеседование?', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        sampSendChat(u8:decode'Здравия желаю, Вас приветствует '..settings.player.rang..' МВД - '..settings.player.username..'')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Вы пришли к нам на собеседование?')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Если да, покажите ваши документы, а именно: паспорт, лицензии и медицинскую карту. ')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/n /pass, /lic, /showmc. по РП, 3 РП строки')
            end)
        end

        if imgui.Button('Тест небольшой', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        sampSendChat(u8:decode'/n Теперь другой тест.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/n При каждом выходе в AFK будет считаться за ошибку')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/n Что означает следующие: ДМ, ТК, СК, FF')
            end)
        end

        imgui.SameLine()
        if imgui.Button('Тест небольшой #2', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        sampSendChat(u8:decode'Теперь небольшой тест.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Что по вашему значит "ТК","МГ" и "ДМ" ?')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Что у меня над головой?')
            end)
        end

        if imgui.Button('Увы, проф.непригодность', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        sampSendChat(u8:decode'К сожaлению вы нам не подходите')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Причина: Проф.непригодность')
            end)
        end

        imgui.SameLine()
        if imgui.Button('Повысить', imgui.ImVec2(230, 30)) then
	    imgui.OpenPopup('Повысить | /rang')
        end
        if imgui.BeginPopupModal('Повысить | /rang', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(400, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял планшет "Xiaomi"')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me включил планшетый ПК')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Планшетный ПК включен.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me зашёл на рабочий стол')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me открыл папку «Повышение сотрудников»')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me выбрал нужного сотрудника')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me повысил сотрудника')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Сотрудник повышен.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/rang ' ..text)
        end)
            else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел время...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Понизить', imgui.ImVec2(230, 30)) then
	    imgui.OpenPopup('Понизить | /rang')
        end
        if imgui.BeginPopupModal('Понизить | /rang', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(400, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял планшет "Xiaomi"')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me включил планшетый ПК')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Планшетный ПК включен.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me зашёл на рабочий стол')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me открыл папку «Понижение сотрудников»')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me выбрал нужного сотрудника')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me повысил сотрудника')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Сотрудник понижен.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/rang ' ..text)
        end)
            else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел время...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        imgui.SameLine()
        if imgui.Button('Выговор', imgui.ImVec2(230, 30)) then
	    imgui.OpenPopup('Выговор | /fwarn')
        end
        if imgui.BeginPopupModal('Выговор | /fwarn', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(400, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял планшет "Xiaomi"')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me включил планшетый ПК')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Планшетный ПК включен.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me зашёл на рабочий стол')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me открыл папку «Выговоры»')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me выбрал нужного сотрудника')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me выдал выговор сотруднику')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Выговор выдан.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/fwarn ' ..text)
        end)
            else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел время...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Пригласить', imgui.ImVec2(230, 30)) then
	    imgui.OpenPopup('Пригласить | /invite')
        end
        if imgui.BeginPopupModal('Пригласить | /invite', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(400, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял планшет "Xiaomi"')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me включил планшетый ПК')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Планшетный ПК включен.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me зашёл на рабочий стол')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me открыл папку «Добавить сотрудников»')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me внес в базу данных нового сотрудника')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me передал униформу')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Униформа выдана.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/invite ' ..text)
        end)
            else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел время...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        imgui.SameLine()
        if imgui.Button('Уволить', imgui.ImVec2(230, 30)) then
	    imgui.OpenPopup('Уволить | /uninvite')
        end
        if imgui.BeginPopupModal('Уволить | /uninvite', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(400, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял планшет "Xiaomi"')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me включил планшетый ПК')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Планшетный ПК включен.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me зашёл на рабочий стол')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me открыл папку «Увольнение сотрудников»')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me выбрал нужного сотрудника')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me уволил сотрудника')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Сотрудник уволен.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/uninvite ' ..text)
        end)
            else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел время...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        imgui.End()
    end)

        imgui.OnFrame(function() return MenuFunction[0] end, function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(480, 420), imgui.Cond.Always)
        imgui.Begin('MVDHelper | Меню', MenuFunction, imgui.WindowFlags.NoResize)

        if imgui.Button('Список команд', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Команды | /mhelp')
        end
        if imgui.BeginPopupModal('Команды | /mhelp', nil, imgui.WindowFlags.NoResize) then
        imgui.SetWindowSizeVec2(imgui.ImVec2(400, 280))
        imgui.Text('CTRL + R | Перезагрузить AHK (Или в основном меню)  \n msm | Отследить преступника \n mdoc | Показать удостоверение \n mdoc2 | Попросить документы \n mdoc3 | Взять паспорт \n mdoc4 | Взять тех.паспорт \n mdoc5 | Взять лицензии \n mdoc6 | Отпустить  \n omondoc | Удостоверение ОМОНА \n mcuff | Надеть наручники в вести за собой \n muncuff | Снять наручники и отпустить \n mclear | Снять звезды \n marrest | Передать в КПЗ \n msu | Выдать звезды \n mpg | Начать погоню \n mtakelic | Забрать лицензии \n mticket | Выдать штраф | \n mputpl | Посадить в машину \n miranda | Миранда \n photo | Фоторобот \n mcheckdocs | Взять документы насильно \n msearch | Обыск \n mattach | Эвакуция ТС')
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        imgui.SameLine()
        if imgui.Button('Отслеживать преступника', imgui.ImVec2(230, 30)) then
	    imgui.OpenPopup('Слежка | /setmark')
        end
        if imgui.BeginPopupModal('Слежка | /setmark', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(400, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        msm = text
        if activate then
            activate = false
            sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Слежка окончена ID: '..msm, -1)
        else
                if msm:match('%d+') then
                    activate = true
            sampAddChatMessage(u8:decode"{006AFF}MVD Helper: {FFFFFF}Начал отслеживать ID: " ..msm, -1)
               
                    lua_thread.create(function ()
                        while activate do
                            wait(slider_msm[0] * 1000)
                            sampSendChat('/setmark '..msm)
                        end
                    end)
                    lua_thread.create(function ()
                        while activate do
                            wait(slider_notification[0] * 1000)
                            sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Слежка идёт за: '..msm, -1)
                        end
                    end)
                else
            sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
             end
        end
    end

        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Удостоверение ОМОНа', imgui.ImVec2(230, 30)) then
	    imgui.OpenPopup('Омон | /doc')
        end
        if imgui.BeginPopupModal('Омон | /doc', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(400, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Работает сотрудник ОМОН | Позывной: '..settings.player.username..'.', -1)
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Предьявите пожалуйста ваши документы, удостоверяющие вашу личность.', -1)
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Если вы в течении 30 секунд не предъявите мне документы, я сочту это за неподчинение!', -1)
        wait(slider_text[0] * 100)
        sampSendChat("/doc " .. text)
        end)
            else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        imgui.SameLine()
        if imgui.Button('Удостоверение', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Представиться | /doc')
        end
        if imgui.BeginPopupModal('Представиться | /doc', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Здравия желаю,вас беспокоит '..settings.player.rang..' '..settings.player.otdel..' - '..settings.player.username..'.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me отдал честь')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/anim 1 7')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me достал из нагрудного кармана удостоверение и предъявил его')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/anim 6 3')
        wait(slider_text[0] * 100)
        sampSendChat("/doc "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Попросить документы', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Предъявите документы, а также отстегните ремень безопасности.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/n /pass [id]; /rem; /carpass [id]; /lic [id]')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me достал ориентировку и сравнил ее с лицом гражданина')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/todo Процесс проверки*При необходимости, мы задержим вас на неопределенное время.')
            end)
        end

        imgui.SameLine()
        if imgui.Button('Взять документы', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me взял документы у человека напротив')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Документы в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me осмотрел паспорт')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me закрыл документы')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Документы закрыты.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me вернул документы человеку напротив')
        wait(slider_text[0] * 100)
        sampSendChat('/anim 6 3')
            end)
        end

        if imgui.Button('Взять документы на ТС', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me взял правой рукой паспорт транспортного средства.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Паспорт транспортного средства в руках.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me открыл документ')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me посмотрел всю нужную информацию')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me закрыл паспорт транспортного средства')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me передал паспорт транспортного средства человеку напротив')
            end)
        end

            imgui.SameLine()
        if imgui.Button('Взять лицензии', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял лицензии у человека напротив')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Лицензии в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me осмотрел лицензии')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me закрыл лицензии')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Лицензии закрыты.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me вернул лицензии человеку напротив')
            end)
    end

        if imgui.Button('Отпустить', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        sampSendChat(u8:decode'Гражданин, у Вас всё в порядке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Можете быть свободны!')
            end)
    end

        imgui.SameLine()
        if imgui.Button('Надеть наручники', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Одеть наручники | /cuff + /escort')
        end
        if imgui.BeginPopupModal('Одеть наручники | /cuff + /escort', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Наручники на поясе.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me снял наручники с пояса')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Наручники в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me схватил руки человека')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Руки схвачены.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me надел наручники на человека напротив')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Наручники надеты.')
        wait(slider_text[0] * 100)
        sampSendChat("/cuff "..text)
        wait(slider_text[0] * 100)
        sampSendChat("/escort "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Снять наручники', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Снять наручники | /uncuff + /escort')
        end
        if imgui.BeginPopupModal('Снять наручники | /uncuff + /escort', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Наручники на руках у человека.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me снял наручники с рук подозреваемого')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Наручники сняты.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me повесил наручники на пояс')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Наручники на поясе.')
        wait(slider_text[0] * 100)
        sampSendChat("/uncuff "..text)
        wait(slider_text[0] * 100)
        sampSendChat("/escort "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        imgui.SameLine()
        if imgui.Button('Снять звезды', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Снять звезды | /clear')
        end
        if imgui.BeginPopupModal('Снять звезды | /clear', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me взял рацию в руки, затем зажал кнопку')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Кнопка зажата.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me сообщил данные подозреваемого диспетчеру')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Данные сообщены диспетчеру.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Диспетчер: С подозреваемого снят розыск.')
        wait(slider_text[0] * 100)
        sampSendChat("/clear "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Посадить в КПЗ', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Посадить в КПЗ | /arrest')
        end
        if imgui.BeginPopupModal('Посадить в КПЗ | /arrest', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me открыл двери МВД')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Двери открыты.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me провел человека в участок')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Человек в участке.')
        wait(slider_text[0] * 100)
        sampSendChat("/arrest "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end
    
        imgui.SameLine()
        if imgui.Button('Выдать розыск', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Выдать розыск | /su')
        end
        if imgui.BeginPopupModal('Выдать розыск | /su', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me взял рацию в руки, затем зажал кнопку')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Кнопка зажата.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me сообщил данные нарушителя диспетчеру')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Нарушитель объявлен в розыск.')
        wait(slider_text[0] * 100)
        sampSendChat("/su "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Начать погоню', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Начать погоню | /pg')
        end
        if imgui.BeginPopupModal('Начать погоню | /pg', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Рация на поясе.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me достал рацию')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/todo Зажав кнопку*Преследую преступника, прием.')
        wait(slider_text[0] * 100)
        sampSendChat("/pg "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        imgui.SameLine()
        if imgui.Button('Выдать штраф', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Выдать штраф | /ticket')
        end
        if imgui.BeginPopupModal('Выдать штраф | /ticket', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID, Сумму, Причина')
        imgui.InputTextWithHint('', 'Пример: 123 5000 10.1 КоАП', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me достал планшет')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Планшет в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me записал данные о нарушении и нарушителе')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Данные заполнены.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me отправил данные в базу данных')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Данные отправлены.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me убрал планшет')
        wait(slider_text[0] * 100)
        sampSendChat("/ticket "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Забрать лицензии', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Забрать лицензии | /takelic')
        end
        if imgui.BeginPopupModal('Забрать лицензии | /takelic', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID, Причина')
        imgui.InputTextWithHint('', 'Пример: 123 10.1 КоАП', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me взял планшет')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Планшет в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me записал данные о нарушении и нарушителе')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Данные обновлены.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me забрал водительские удостоверение')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Водительское удостоверение забрано.')
        wait(slider_text[0] * 100)
        sampSendChat("/takelic "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end
    
        imgui.SameLine()
        if imgui.Button('Посадить в машину', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Посадить в машину | /putpl')
        end
        if imgui.BeginPopupModal('Посадить в машину | /putpl', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me открыл дверь машины')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me затащил преступника в машину')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me закрыл дверь')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Дверь закрыта.')
        wait(slider_text[0] * 100)
        sampSendChat("/putpl "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Миранда', imgui.ImVec2(230, 30)) then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Гражданин, Вы будете задержаны до выяснения обстоятельств.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Если вы не согласны с задержанием, то Вы можете обратиться в суд.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Вы имеете право на адвоката.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/n ->>> /adlist')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Советуем хранить молчание.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Так как все Ваши слова будут использованы против Вас.')
            end)
        end

        imgui.SameLine()
        if imgui.Button('Фоторобот', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Фоторобот')
        end
        if imgui.BeginPopupModal('Фоторобот', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do На человеке надеты вещи.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me сорвал все лишнее, что мешает для опознания по лицу')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Вещи упали на землю.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do КПК в руках.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me зашел в приложение МВД')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/police_tablet ')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me сфотографировав человека, загрузил фото в приложении')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Поиск по фото.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Человек распознан')
        wait(slider_text[0] * 100)
        sampSendChat("/id "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
            if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Насильно взять документы', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Насильно взять документы | /checkdocs')
        end
        if imgui.BeginPopupModal('Насильно взять документы | /checkdocs', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me протянул руку затем провел по карманам легким движением руки')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Проводит по карманам...')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me засунул руку в карман затем достал документы')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Документы достаны.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me взял открыл документ')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/todo Изучает документ * Ну что ничего иного я и не ожидал наш клиент.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me закрыл документ затем положил его обратно в карман')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Документ в кармане.')
        wait(slider_text[0] * 100)
        sampSendChat("/checkdocs "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        imgui.SameLine()
        if imgui.Button('Выкинуть из машины', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Насильно выкинуть из машины | /mejectout')
        end
        if imgui.BeginPopupModal('Насильно выкинуть из машины | /mejectout', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me разбил окно автомобиля, затем открыл дверь изнутри')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Дверь автомобиля открыта.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me вытащил человека из автомобиля')
        wait(slider_text[0] * 100)
        sampSendChat("/ejectout "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end

        if imgui.Button('Обсык', imgui.ImVec2(230, 30)) then
        imgui.OpenPopup('Провести обыск | /msearch')
        end
        if imgui.BeginPopupModal('Провести обыск | /msearch', _, imgui.WindowFlags.NoResize, main_window_state) then
	    imgui.SetWindowSizeVec2(imgui.ImVec2(370, 258))
        imgui.Text('Введите ID')
        imgui.InputTextWithHint('', 'Пример: 123', inputField, 256)
        if imgui.Button('Включить') then
        imgui.CloseCurrentPopup()
        text = u8:decode(ffi.string(inputField))
        if text:find('(%d+)') then
        lua_thread.create(function()
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Перчатки с надписью "МВД" на руках.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me начал ощупывать человека напротив')
        wait(slider_text[0] * 100)
        sampSendChat('/anim 5 1')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Верхняя часть осмотрена.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me начал щупать в области ног')
        wait(slider_text[0] * 100)
        sampSendChat('/anim 6 1')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Нижняя часть осмотрена.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me усмехнулся')
        wait(slider_text[0] * 100)
        sampSendChat("/search "..text)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
        if imgui.Button('Закрыть', imgui.ImVec2(130, 24)) then
        imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
        end
        
     imgui.SameLine()
     if imgui.Button('Эвакуация ТС', imgui.ImVec2(230, 30)) then
    lua_thread.create(function()
    sampSendChat(u8:decode'/do Бортовой компьютер Дорожно-Патрульной Службы выключен.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me включил бортовой компьютер Дорожно-Патрульной Службы')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Бортовой компьютер Дорожно-Патрульной Службы включён.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me нажал на кнопку "Фотография" и сделал фотографию')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Фотография сохранена на базе данных Дорожно-Патрульной Службы.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me нажал на кнопку выключения бортового компьютера Дорожно-Патрульной Службы')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Бортовой компьютер Дорожно-Патрульной Службы выключен.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me поставил эвакуатор на ручник')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Эвакуатор стоит на ручнике.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me отпустил кран эвакуатора')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Кран эвакуатора отпущен.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me зацепил транспортное средство')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Транспортное средство зацеплено.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me поднимает кран эвакуатора')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Кран эвакуатора поднят.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me эвакуирует транспортное средство')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Эвакуатор готов к движению.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me отпустил ручник на эвакуаторе')
    wait(slider_text[0] * 100)
    sampSendChat('/attach')
    wait(1000)
    sampSendChat(u8:decode'/r ['..settings.player.tag.. u8:decode'] Докладывает: '..settings.player.username.. u8:decode'. Начиная эвакуацию ТС на ШС.')
    wait(1000)
    sampSendChat('/c 060')
    wait(100)
    setVirtualKeyDown(119, true)
    wait(500)
    setVirtualKeyDown(119, false)
        end)
    end
        imgui.End()
    end)

    function getTableUsersByUrl(url)
        local n_file, bool, users = os.getenv('TEMP')..os.time(), false, {}
        downloadUrlToFile(url, n_file, function(id, status)
            if status == 6 then bool = true end
        end)
        while not doesFileExist(n_file) do wait(0) end
        if bool then
            local file = io.open(n_file, 'r')
            for w in file:lines() do
                local n, d = w:match('(.*): (.*)')
                users[#users+1] = { name = n, date = d }
            end
            file:close()
            os.remove(n_file)
        end
        return users
    end

    function isAvailableUser(users, name)
        for i, k in pairs(users) do
            if k.name == name then
                local d, m, y = k.date:match('(%d+)%.(%d+)%.(%d+)')
                local time = {
                    day = tonumber(d),
                    isdst = true,
                    wday = 0,
                    yday = 0,
                    year = tonumber(y),
                    month = tonumber(m),
                    hour = 0
                }
                if os.time(time) >= os.time() then return true end
            end
        end
        return false
    end

    site = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/users.txt'

    function main()
        while not isSampAvailable() do wait(0) end
        while sampGetCurrentServerName() == 'SA-MP' do wait(0) end
        local users = getTableUsersByUrl(site)
        local _, myid = sampGetPlayerIdByCharHandle(playerPed)
        if not isAvailableUser(users, sampGetPlayerNickname(myid)) then
        sampAddChatMessage(u8:decode'{FF0000}AHK не активирован. Обратитесь в Support за активацией!', -1)
        print(u8:decode'AHK не активирован. Обратитесь в Support за активацией!')
        thisScript():unload()
        end
        if isAvailableUser(users, sampGetPlayerNickname(myid)) then
        sampAddChatMessage(u8:decode'{32CD32}AHK успешно активирован! Можете им пользоваться! Открыть ALT + 3', -1)
        print(u8:decode'AHK успешно активирован! Можете им пользоваться! Открыть ALT + 3')
        if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
        end
        sampRegisterChatCommand('msm', msm)
        sampRegisterChatCommand('mdoc', mdoc)
        sampRegisterChatCommand('mdoc2', mdoc2)
        sampRegisterChatCommand('mdoc3', mdoc3)
        sampRegisterChatCommand('mdoc4', mdoc4)
        sampRegisterChatCommand('mdoc5', mdoc5)
        sampRegisterChatCommand('mdoc6', mdoc6)
        sampRegisterChatCommand('omondoc', omondoc)
        sampRegisterChatCommand('mcuff', mcuff)
        sampRegisterChatCommand('muncuff', muncuff)
        sampRegisterChatCommand('mclear', mclear)
        sampRegisterChatCommand('marrest', marrest)
        sampRegisterChatCommand('msu', msu)
        sampRegisterChatCommand('mpg', mpg)
        sampRegisterChatCommand('mtakelic', mtakelic)
        sampRegisterChatCommand('mticket', mticket)
        sampRegisterChatCommand('mputpl', mputpl)
        sampRegisterChatCommand('miranda', miranda)
        sampRegisterChatCommand('photo', photo)
        sampRegisterChatCommand('mcheckdocs', mcheckdocs)
        sampRegisterChatCommand('mejectout', mejectout)
        sampRegisterChatCommand('msearch', msearch)
        sampRegisterChatCommand('mattach', mattach)
        sampRegisterChatCommand('r', r)
	    lua_thread.create(function()
        HotkeyCFGMenuMVD = hotkey.RegisterHotKey('HotkeyCFGMenuMVD', false, decodeJson(settings.hotkey_cfg.bind), function()
            if not sampIsCursorActive() then
                MenuMVD[0] = not MenuMVD[0]
                end
            end)
        end)

        lua_thread.create(function()
        HotkeyCFGFunction = hotkey.RegisterHotKey('HotkeyCFGFunction', false, decodeJson(settings.hotkey_cfg.bind2), function()
            if not sampIsCursorActive() then
                MenuFunction[0] = not MenuFunction[0]
                end
            end)
        end)

        lua_thread.create(function()
        HotkeyCFGKoap = hotkey.RegisterHotKey('HotkeyCFGKoap', false, decodeJson(settings.hotkey_cfg.bind3), function()
            if not sampIsCursorActive() then
                MenuKoap[0] = not MenuKoap[0]
                end
            end)
        end)
        lua_thread.create(function()
        HotkeyCFGLeader = hotkey.RegisterHotKey('HotkeyCFGLeader', false, decodeJson(settings.hotkey_cfg.bind5), function()
            if not sampIsCursorActive() then
                MenuLeader[0] = not MenuLeader[0]
                end
            end)
        end)
        lua_thread.create(function()
        HotkeyCFGMsm = hotkey.RegisterHotKey('HotkeyCFGMsm', false, decodeJson(settings.hotkey_cfg.bind4), function()
            stop = true
        end)
        while true do
            wait(0)
            if stop then
                stop = false 
                if activate then
                    activate = false
                    sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Слежка остановлена!', -1)
                end
                wait(500)
                end
            end
        end)
        local servers = {
        ["185.169.134.139"] = "koap01",
        ["185.169.134.140"] = "koap02",
        ["80.66.71.76"] = "koap03",
        ["80.66.71.77"] = "koap04",
        ["185.169.134.35"] = "koap05",
        ["185.169.134.36"] = "koap06",
        ["80.66.71.74"] = "koap07",
        ["80.66.71.75"] = "koap08",
        ["185.169.134.123"] = "koap09",
        ["185.169.134.124"] = "koap10",
        ["80.66.71.80"] = "koap11",
        ["80.66.71.81"] = "koap12",
        ["80.66.71.78"] = "koap13",
        ["80.66.71.79"] = "koap14",
        ["80.66.71.82"] = "koap15",
        ["80.66.71.83"] = "koap16",
        ["80.66.71.84"] = "koap17",
        ["80.66.71.61"] = "koap18",
        ["80.66.71.71"] = "koap19",
        ["80.66.71.91"] = "koap20",
        ["80.66.71.92"] = "koap21",
    }
    local ip, port = sampGetCurrentServerAddress()
    local function readFileContent(serverName)
        local fileName = getWorkingDirectory() .. '\\MVDHelper\\' .. serverName .. '.txt'
        local file = io.open(fileName, 'r')
        if file then
            local content = file:read('*a')
            file:close()
            return content
        else
            return "{FF0000}Файл не найден: " .. fileName
        end
    end
        imgui.OnFrame(function() return MenuKoap[0] end, function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(1000, 700), imgui.Cond.Always)
        imgui.Begin('MVDHelper | КоАП', MenuKoap, imgui.WindowFlags.NoResize)
                if servers[ip] then
                    local content = readFileContent(servers[ip])
                    imgui.TextColoredRGB(u8:decode(content))
                else
                    imgui.TextColoredRGB(u8("{FF0000}Неизвестный сервер"))
                end

        imgui.End()
    end)
    end
        if not doesDirectoryExist(getWorkingDirectory()..'\\MVDHelper') then
        createDirectory(getWorkingDirectory()..'\\MVDHelper')
    end
        for i, v in ipairs(sounds) do
        if not doesFileExist(getWorkingDirectory()..'\\MVDHelper\\'..v['file_name']) then
        print(u8:decode'Загружаю: ' .. v['file_name'], -1)
        downloadUrlToFile(v['url'], getWorkingDirectory()..'\\MVDHelper\\'..v['file_name'])
    end
        local stream = loadAudioStream(getWorkingDirectory()..'\\MVDHelper\\'..v['file_name'])
        if stream then
        table.insert(sound_streams, stream)
            end
        end
        while not isSampAvailable() do
        wait(100)
                end
    end

    function playRandomSound()
        if #sound_streams > 0 then
            local random_index = math.random(1, #sound_streams)
            local stream = sound_streams[random_index]
            setAudioStreamState(stream, as_action.PLAY)
            setAudioStreamVolume(stream, settings.volume_settings.volume)
        else
            sampAddChatMessage(u8:decode'Нет доступных звуков для воспроизведения.', -1)
        end
    end

    function r(arg)
    if arg:find('(.*)') then
    sampSendChat('/r ['..settings.player.tag..'] '..arg)
    else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
end

     function msm(arg)
     if enabling_msm[0] then
        msm = arg
        if activate then
            activate = false
            sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Слежка окончена ID: '..msm, -1)
        else
                if msm:match('%d+') then
                    activate = true
            sampAddChatMessage(u8:decode"{006AFF}MVD Helper: {FFFFFF}Начал отслеживать ID: " ..msm, -1)
               
                    lua_thread.create(function ()
                        while activate do
                            wait(slider_msm[0] * 1000)
                            sampSendChat('/setmark '..msm)
                        end
                    end)
                    lua_thread.create(function ()
                        while activate do
                            wait(slider_notification[0] * 1000)
                            sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Слежка идёт за: '..msm, -1)
                        end
                    end)
                else
            sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
                end
            end
        end
    end

    function msearch(arg)
     if enabling_marrest[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/do Перчатки с надписью "МВД" на руках.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me начал ощупывать человека напротив')
        wait(slider_text[0] * 100)
        sampSendChat('/anim 5 1')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Верхняя часть осмотрена.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me начал щупать в области ног')
        wait(slider_text[0] * 100)
        sampSendChat('/anim 6 1')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Нижняя часть осмотрена.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me усмехнулся')
        wait(slider_text[0] * 100)
        sampSendChat("/search "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function omondoc(arg)
     if enabling_omondoc[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'Работает сотрудник ОМОН | Позывной: '..settings.player.username..'.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Предьявите пожалуйста ваши документы, удостоверяющие вашу личность.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Если вы в течении 30 секунд не предъявите мне документы я сочту это за неподчинение!')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode"/doc " ..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
                end
            end
        end

    function mdoc(arg)
     if enabling_mdoc[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'Здравия желаю,вас беспокоит '..settings.player.rang..' '..settings.player.otdel..' - '..settings.player.username..'.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me отдал честь')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/anim 1 7')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me достал из нагрудного кармана удостоверение и предъявил его')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/anim 6 3')
        wait(slider_text[0] * 100)
        sampSendChat("/doc "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

     function mdoc2()
     if enabling_mdoc2[0] then
        lua_thread.create(function()
        sampSendChat(u8:decode'Предъявите документы, а также отстегните ремень безопасности.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/n /pass [id]; /rem; /carpass [id]; /lic [id]')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me достал ориентировку и сравнил ее с лицом гражданина')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/todo Процесс проверки*При необходимости, мы задержим вас на неопределенное время.')
            end)
        end
    end

     function mdoc3()
     if enabling_mdoc3[0] then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял документы у человека напротив')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Документы в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me осмотрел паспорт')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me закрыл документы')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Документы закрыты.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me вернул документы человеку напротив')
            end)
        end
    end

     function mdoc4()
     if enabling_mdoc4[0] then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял тех.паспорт у человека напротив')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Тех.паспорт в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me осмотрел тех.паспорт')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me закрыл тех.паспорт')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Тех.паспорт закрыты.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me вернул тех.паспорт человеку напротив')
            end)
        end
    end

     function mdoc5()
     if enabling_mdoc5[0] then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял лицензии у человека напротив')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Лицензии в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me осмотрел лицензии')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me закрыл лицензии')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Лицензии закрыты.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me вернул лицензии человеку напротив')
            end)
        end
    end

     function mdoc6()
     if enabling_mdoc6[0] then
        lua_thread.create(function()
        sampSendChat(u8:decode'Гражданин, у Вас всё в порядке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Можете быть свободны!')
            end)
        end
    end

    function mcuff(arg)
     if enabling_mcuff[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/do Наручники на поясе.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me снял наручники с пояса')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Наручники в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me схватил руки человека')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Руки схвачены.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me надел наручники на человека напротив')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Наручники надеты.')
        wait(slider_text[0] * 100)
        sampSendChat("/cuff "..arg)
        wait(slider_text[0] * 100)
        sampSendChat("/escort "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function muncuff(arg)
     if enabling_muncuff[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/do Наручники на руках у человека.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me снял наручники с рук подозреваемого')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Наручники сняты.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me повесил наручники на пояс')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Наручники на поясе.')
        wait(slider_text[0] * 100)
        sampSendChat("/uncuff "..arg)
        wait(slider_text[0] * 100)
        sampSendChat("/escort "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function mclear(arg)
     if enabling_mclear[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял рацию в руки, затем зажал кнопку')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Кнопка зажата.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me сообщил данные подозреваемого диспетчеру')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Данные сообщены диспетчеру.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Диспетчер: С подозреваемого снят розыск.')
        wait(slider_text[0] * 100)
        sampSendChat("/clear "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function marrest(arg)
     if enabling_marrest[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me открыл двери МВД')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Двери открыты.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me провел человека в участок')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Человек в участке.')
        wait(slider_text[0] * 100)
        sampSendChat("/arrest "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function msu(arg)
     if enabling_msu[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял рацию в руки, затем зажал кнопку')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Кнопка зажата.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me сообщил данные нарушителя диспетчеру')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Нарушитель объявлен в розыск.')
        wait(slider_text[0] * 100)
        sampSendChat("/su "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function mpg(arg)
     if enabling_mpg[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/do Рация на поясе.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me достал рацию')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/todo Зажав кнопку*Преследую преступника, прием.')
        wait(slider_text[0] * 100)
        sampSendChat("/pg "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function mtakelic(arg)
     if enabling_mtakelic[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me взял планшет')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Планшет в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me записал данные о нарушении и нарушителе')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Данные обновлены.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me забрал водительские удостоверение')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Водительское удостоверение забрано.')
        wait(slider_text[0] * 100)
        sampSendChat("/takelic "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function mticket(arg)
     if enabling_mticket[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me достал планшет')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Планшет в руке.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me записал данные о нарушении и нарушителе')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Данные заполнены.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me отправил данные в базу данных')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Данные отправлены.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me убрал планшет')
        wait(slider_text[0] * 100)
        sampSendChat("/ticket "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function mputpl(arg)
     if enabling_mputpl[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me открыл дверь машины')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me затащил преступника в машину')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me закрыл дверь')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Дверь закрыта.')
        wait(slider_text[0] * 100)
        sampSendChat("/putpl "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function miranda()
     if enabling_miranda[0] then
        lua_thread.create(function()
        sampSendChat(u8:decode'Гражданин, Вы будете задержаны до выяснения обстоятельств.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Если вы не согласны с задержанием, то Вы можете обратиться в суд.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Вы имеете право на адвоката.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/n ->>> /adlist')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Советуем хранить молчание.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'Так как все Ваши слова будут использованы против Вас.')
            end)
        end
    end

    function photo(arg)
     if enabling_photo[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/do На человеке надеты вещи.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me сорвал все лишнее, что мешает для опознания по лицу')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Вещи упали на землю.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do КПК в руках.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me зашел в приложение МВД')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/police_tablet ')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me сфотографировав человека, загрузил фото в приложении')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Поиск по фото.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Человек распознан')
        wait(slider_text[0] * 100)
        sampSendChat("/id "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function mcheckdocs(arg)
     if enabling_mcheckdocs[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me протянул руку затем провел по карманам легким движением руки')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Проводит по карманам...')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me засунул руку в карман затем достал документы')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Документы достаны.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me взял открыл документ')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/todo Изучает документ * Ну что ничего иного я и не ожидал наш клиент.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me закрыл документ затем положил его обратно в карман')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Документ в кармане.')
        wait(slider_text[0] * 100)
        sampSendChat("/checkdocs "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

    function mejectout(arg)
     if enabling_mejectout[0] then
        if arg:find('(%d+)') then
        lua_thread.create(function()
        sampSendChat(u8:decode'/me разбил окно автомобиля, затем открыл дверь изнутри')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/do Дверь автомобиля открыта.')
        wait(slider_text[0] * 100)
        sampSendChat(u8:decode'/me вытащил человека из автомобиля')
        wait(slider_text[0] * 100)
        sampSendChat("/ejectout "..arg)
            end)
                else
                sampAddChatMessage(u8:decode'{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

function mattach()
     if enabling_mattach[0] then
    lua_thread.create(function()
    sampSendChat(u8:decode'/do Бортовой компьютер Дорожно-Патрульной Службы выключен.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me включил бортовой компьютер Дорожно-Патрульной Службы')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Бортовой компьютер Дорожно-Патрульной Службы включён.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me нажал на кнопку "Фотография" и сделал фотографию')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Фотография сохранена на базе данных Дорожно-Патрульной Службы.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me нажал на кнопку выключения бортового компьютера Дорожно-Патрульной Службы')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Бортовой компьютер Дорожно-Патрульной Службы выключен.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me поставил эвакуатор на ручник')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Эвакуатор стоит на ручнике.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me отпустил кран эвакуатора')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Кран эвакуатора отпущен.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me зацепил транспортное средство')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Транспортное средство зацеплено.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me поднимает кран эвакуатора')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Кран эвакуатора поднят.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me эвакуирует транспортное средство')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/do Эвакуатор готов к движению.')
    wait(slider_text[0] * 100)
    sampSendChat(u8:decode'/me отпустил ручник на эвакуаторе')
    wait(slider_text[0] * 100)
    sampSendChat('/attach')
    wait(1000)
    sampSendChat(u8:decode'/r ['..settings.player.tag.. u8:decode'] Докладывает: '..settings.player.username.. u8:decode'. Начиная эвакуацию ТС на ШС.')
    wait(1000)
    sampSendChat('/c 060')
    wait(100)
    setVirtualKeyDown(119, true)
    wait(500)
    setVirtualKeyDown(119, false)
        end)
    end
end

function ev.onServerMessage(color, text)
    if settings.volume_settings.music then
    if text:find(u8:decode'(%w+_%w+) был доставлен в тюрьму для отбывания наказания') then
        playRandomSound()
        end
    end
    if text:find(u8:decode'Транспорт отправлен на штрафстоянку') then
    sampSendChat(u8:decode'/r ['..settings.player.tag.. u8:decode'] Докладывает: '..settings.player.username.. u8:decode'. Доставил ТС на ШС.')
    end
end

    function ev.onPlayerQuit(playerId, reason)
        local result, playerChar = sampGetCharHandleBySampPlayerId(playerId)
        if not result then
            return nil
        end

        local px, py, pz = getCharCoordinates(playerChar)
        local mx, my, mz = getCharCoordinates(PLAYER_PED)

        if getDistanceBetweenCoords3d(px, py, pz, mx, my, mz) <= 50 then
            local nickname = sampGetPlayerNickname(playerId)
            local notifyMessage = table.concat({
                (u8:decode"Игрок %s(%d) покинул игру"):format(nickname, playerId),
                u8:decode"",
                quitReasons[reason] or u8:decode"Неизвестная причина",
                (u8:decode"Время: %s"):format(os.date("%H:%M:%S"))
            }, "\n")

            createQuitNotify(px, py, pz, notifyMessage)
        end
    end

    function ev.onCreate3DText(id, ...)
        if notifyPool[id] ~= nil then
            notifyPool[id] = nil
        end
    end

    function ev.onRemove3DTextLabel(id)
        if notifyPool[id] ~= nil then
            return false
        end
    end

    function createQuitNotify(x, y, z, text)
        local id = sampCreate3dText(text, 0xAAFFFFFF, x, y, z, 25, false, -1, -1)
        notifyPool[id] = os.clock() + duration

        lua_thread.create(function()
            while notifyPool[id] and os.clock() < notifyPool[id] do
                wait(0)
            end
            removeQuitNotify(id)
        end)
    end

    function removeQuitNotify(id)
        if notifyPool[id] == nil then
            return nil
        end

        if sampIs3dTextDefined(id) then
            sampDestroy3dText(id)
        end

        notifyPool[id] = nil
    end

    function onScriptTerminate(script, isQuit)
        if script == thisScript() then
            for id, time in pairs(notifyPool) do
                removeQuitNotify(id)
            end
        end
    end

    theme = {
            {
    -- красная
    change = function()
    local style = imgui.GetStyle()
    style.WindowRounding = 6
    style.FrameRounding = 4
    style.PopupRounding = 4
    style.GrabRounding = 4
    style.ScrollbarRounding = 4
    style.WindowBorderSize = 1
    local colors = style.Colors
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.3, 0.0, 0.0, 0.7)  
    colors[imgui.Col.TitleBg] = imgui.ImVec4(0.5, 0.0, 0.0, 0.8)   
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.7, 0.0, 0.0, 0.8)
    colors[imgui.Col.Border] = imgui.ImVec4(1.0, 0.2, 0.2, 0.8)  
    colors[imgui.Col.Button] = imgui.ImVec4(0.8, 0.1, 0.1, 0.8)    
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(1.0, 0.2, 0.2, 0.8)
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(1.0, 0.0, 0.0, 0.9)
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.4, 0.0, 0.0, 0.7)
    colors[imgui.Col.Text] = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)   
    end
            },
            {
    -- синяя
    change = function()
    local style = imgui.GetStyle()
    style.WindowRounding = 6
    style.FrameRounding = 4
    style.PopupRounding = 4
    style.GrabRounding = 4
    style.ScrollbarRounding = 4
    style.WindowBorderSize = 1
    local colors = style.Colors
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.0, 0.0, 0.3, 0.7)  
    colors[imgui.Col.TitleBg] = imgui.ImVec4(0.0, 0.2, 0.5, 0.8)   
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.0, 0.3, 0.7, 0.8)
    colors[imgui.Col.Border] = imgui.ImVec4(0.2, 0.5, 1.0, 0.8)  
    colors[imgui.Col.Button] = imgui.ImVec4(0.1, 0.3, 0.8, 0.8)    
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.2, 0.4, 1.0, 0.8)
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.1, 0.5, 1.0, 0.9)
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.0, 0.1, 0.4, 0.7)
    colors[imgui.Col.Text] = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)     
    end
            },
            {
     -- фиол
    change = function()
    local style = imgui.GetStyle()
    style.WindowRounding = 6
    style.FrameRounding = 4
    style.PopupRounding = 4
    style.GrabRounding = 4
    style.ScrollbarRounding = 4
    style.WindowBorderSize = 1
    local colors = style.Colors
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.1, 0.0, 0.2, 0.95)
    colors[imgui.Col.TitleBg] = imgui.ImVec4(0.4, 0.0, 0.6, 1.0)
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.6, 0.0, 0.8, 1.0)
    colors[imgui.Col.Border] = imgui.ImVec4(0.9, 0.2, 1.0, 1.0)
    colors[imgui.Col.Button] = imgui.ImVec4(0.5, 0.0, 0.8, 1.0)
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.7, 0.2, 1.0, 1.0)
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.9, 0.3, 1.0, 1.0)
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.2, 0.0, 0.4, 1.0)
    colors[imgui.Col.Text] = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)    
    end
            },
            {
     -- черная
    change = function()
    local style = imgui.GetStyle()
    style.WindowRounding = 6
    style.FrameRounding = 4
    style.PopupRounding = 4
    style.GrabRounding = 4
    style.ScrollbarRounding = 4
    style.WindowBorderSize = 1
    local colors = style.Colors
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.05, 0.05, 0.05, 0.95)
    colors[imgui.Col.TitleBg] = imgui.ImVec4(0.1, 0.1, 0.1, 1.0)
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.15, 0.15, 0.15, 1.0)
    colors[imgui.Col.Border] = imgui.ImVec4(0.3, 0.3, 0.3, 1.0)
    colors[imgui.Col.Button] = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.3, 0.3, 0.3, 1.0)
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.4, 0.4, 0.4, 1.0)
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.1, 0.1, 0.1, 1.0)
    colors[imgui.Col.Text] = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)
    end
            }
            }

    function decor()
        imgui.SwitchContext()
        local ImVec4 = imgui.ImVec4
        imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
        imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
        imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
        imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
        imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
        imgui.GetStyle().IndentSpacing = 0
        imgui.GetStyle().ScrollbarSize = 10
        imgui.GetStyle().GrabMinSize = 10
        imgui.GetStyle().WindowBorderSize = 1
        imgui.GetStyle().ChildBorderSize = 1
        imgui.GetStyle().PopupBorderSize = 1
        imgui.GetStyle().FrameBorderSize = 1
        imgui.GetStyle().TabBorderSize = 1
        imgui.GetStyle().WindowRounding = 8
        imgui.GetStyle().ChildRounding = 8
        imgui.GetStyle().FrameRounding = 8
        imgui.GetStyle().PopupRounding = 8
        imgui.GetStyle().ScrollbarRounding = 8
        imgui.GetStyle().GrabRounding = 8
        imgui.GetStyle().TabRounding = 8
    end

    function imgui.TextColoredRGB(text)
        local style = imgui.GetStyle()
        local colors = style.Colors
        local ImVec4 = imgui.ImVec4
        local explode_argb = function(argb)
            local a = bit.band(bit.rshift(argb, 24), 0xFF)
            local r = bit.band(bit.rshift(argb, 16), 0xFF)
            local g = bit.band(bit.rshift(argb, 8), 0xFF)
            local b = bit.band(argb, 0xFF)
            return a, r, g, b
        end
        local getcolor = function(color)
            if color:sub(1, 6):upper() == 'SSSSSS' then
                local r, g, b = colors[1].x, colors[1].y, colors[1].z
                local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
                return ImVec4(r, g, b, a / 255)
            end
            local color = type(color) == 'string' and tonumber(color, 16) or color
            if type(color) ~= 'number' then return end
            local r, g, b, a = explode_argb(color)
            return imgui.ImVec4(r/255, g/255, b/255, a/255)
        end
        local render_text = function(text_)
            for w in text_:gmatch('[^\r\n]+') do
                local text, colors_, m = {}, {}, 1
                w = w:gsub('{(......)}', '{%1FF}')
                while w:find('{........}') do
                    local n, k = w:find('{........}')
                    local color = getcolor(w:sub(n + 1, k - 1))
                    if color then
                        text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                        colors_[#colors_ + 1] = color
                        m = n
                    end
                    w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
                end
                if text[0] then
                    for i = 0, #text do
                        imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                        imgui.SameLine(nil, 0)
                    end
                    imgui.NewLine()
                else imgui.Text(u8(w)) end
            end
        end
        render_text(text)
    end

    imgui.OnInitialize(function()
        decor()
        theme[colorListNumber[0]+1].change()
        imgui.GetIO().IniFilename = nil
        local config = imgui.ImFontConfig()
        config.MergeMode = true
        config.PixelSnapH = true
        iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
        imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges)
        if doesFileExist(getWorkingDirectory()..'\\MVDHelper\\logo.png') then
            imhandle = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\MVDHelper\\logo.png')
        end
    end)
