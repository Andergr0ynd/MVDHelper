script_name("MVDHelper")
script_version("v1")

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

-- Автообновление
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
     surname = '',
     rrtag = '',
    },
    hotkey_cfg = {
        bind = '[49]',
        bind2 = '[50]',
        bind3 = '[51]',
        bind4 = '[52]',
    },
    slider_settings = {
        slider_msm = 1,
        slider_notification = 5,
    },
    volume_settings = {
        volume = 1,
        music = false,
    },
    color = {
        theme = '1',
    },
}, 'MVDHelper.ini')

-- mimgui
local tab = 1
local MenuMVD = new.bool()
local MenuFunction = new.bool()
local MenuKoap = new.bool()

-- Hotkey
local HotkeyCFGMenuMVD
local HotkeyCFGFunction
local HotkeyCFGKoap
local HotkeyCFGMsm
local sw, sh = getScreenResolution()
local mainWindow = imgui.new.bool(true)

-- local mimgui
local InputUsername = new.char[256](u8(settings.player.username))
local InputTag = new.char[256](u8(settings.player.tag))
local InputRang = new.char[256](u8(settings.player.rang))
local InputOtdel = new.char[256](u8(settings.player.otdel))
local InputSurname = new.char[256](u8(settings.player.surname))
local InputRRTag = new.char[256](u8(settings.player.rrtag))

-- slider
local slider_msm = imgui.new.int(settings.slider_settings.slider_msm)
local slider_notification = imgui.new.int(settings.slider_settings.slider_notification)
local sliderBuf = new.int()

-- volume / music
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
        url = 'https://raw.githubusercontent.com/Andergr0ynd/MVDHelper/refs/heads/main/koap/koap07_2.txt',
        file_name = 'koap07_2.txt',
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

-- Стили mimgui
local colorList = {u8'Красная', u8'Синяя', u8'Фиолетовая', u8'Белая', u8'Черная'}
local colorListNumber = new.int(tonumber(settings.color.theme) or 0)
local colorListBuffer = new['const char*'][#colorList](colorList)

-- msm
local activate = false
local stop = false

imgui.OnFrame(function() return MenuMVD[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(650, 350), imgui.Cond.Always)
    imgui.Begin(u8'MVDHelper | Settings', MenuMVD, imgui.WindowFlags.NoResize)
    if imgui.BeginChild('Menu', imgui.ImVec2(180, 313), true) then
    imgui.Image(imhandle, imgui.ImVec2(160, 60))
    if imgui.Button(u8'Настройки', imgui.ImVec2(160, 30)) then tab = 1 end
    if imgui.Button(u8'Настройки | Отыгровки', imgui.ImVec2(160, 30)) then tab = 2 end
    if imgui.Button(u8'Бинды | AutoHotkey', imgui.ImVec2(160, 30)) then tab = 3 end
    if imgui.Button(u8'Дополнительно', imgui.ImVec2(160, 30)) then tab = 4 end
    imgui.EndChild()
end
    imgui.SameLine()
    if imgui.BeginChild('Function', imgui.ImVec2(440, 313), true) then
    if tab == 1 then
	imgui.Text(u8'Интервал для setmark | msm')
	if imgui.SliderInt('', slider_msm, 1, 5) then 
	settings.slider_settings.slider_msm = slider_msm[0]
	ini.save(settings, 'MVDHelper.ini')
end
	imgui.Text(u8'Интервал уведомлений')
	if imgui.SliderInt(' ', slider_notification, 5, 10) then 
	settings.slider_settings.slider_notification = slider_notification[0]
	ini.save(settings, 'MVDHelper.ini')
end
    imgui.Separator()
	imgui.Text(u8'Громкость')
	if imgui.SliderInt("##volume", volume_settings, 0, 10) then
	if music ~= nil then setAudioStreamVolume(music, volume.v / 10) end
	settings.volume_settings.volume = volume_settings[0]
	ini.save(settings, 'MVDHelper.ini')
end
	if imgui.Button(u8'Проверка звука', imgui.ImVec2(137, 30)) then
	playRandomSound()
end
    if imgui.Checkbox(u8'Включить звук', music_settings) then
    settings.volume_settings.music = music_settings[0]
    ini.save(settings, 'MVDHelper.ini')
end

elseif tab == 2 then
    imgui.Text(u8'Для отыгровок')
    imgui.SetNextItemWidth(234)if imgui.InputTextWithHint(u8'Nick_Name', u8'Имя Фамилия | Позывной', InputUsername, 256) then end
	imgui.SetNextItemWidth(234)if imgui.InputTextWithHint(u8'Тэг', u8'С', InputTag, 256) then end
    imgui.SetNextItemWidth(234)if imgui.InputTextWithHint(u8'Звание', u8'Сержант', InputRang, 256) then end
    imgui.SetNextItemWidth(234)if imgui.InputTextWithHint(u8'Отдел', u8'ДПС | ППС | ОМОН', InputOtdel, 256) then end

    imgui.Separator()
    imgui.Text(u8'Для рации')
    imgui.SetNextItemWidth(234)if imgui.InputTextWithHint(u8'Тэг ', u8'С ', InputRRTag, 256) then end
    imgui.SetNextItemWidth(234)if imgui.InputTextWithHint(u8'Пост | Патруль | Эвакуация ТС', u8'Фамилия', InputSurname, 256) then end

    settings.player.username = u8:decode(str(InputUsername))
	settings.player.tag = u8:decode(str(InputRang))
    settings.player.rang = u8:decode(str(InputRang))
	settings.player.otdel = u8:decode(str(InputOtdel))
    settings.player.surname = u8:decode(str(InputSurname))
    settings.player.rrtag = u8:decode(str(InputRRTag))
	ini.save(settings, 'MVDHelper.ini')
elseif tab == 3 then
    imgui.Text(u8'Открытие настроек')
    if HotkeyCFGMenuMVD:ShowHotKey() then
    settings.hotkey_cfg.bind = encodeJson(HotkeyCFGMenuMVD:GetHotKey())
    ini.save(settings, 'MVDHelper.ini')
end
    imgui.Text(u8'Открытие меню')
    if HotkeyCFGFunction:ShowHotKey() then
    settings.hotkey_cfg.bind2 = encodeJson(HotkeyCFGFunction:GetHotKey())
    ini.save(settings, 'MVDHelper.ini')
end
    imgui.Text(u8'Открытие КоАП')
    if HotkeyCFGKoap:ShowHotKey() then
    settings.hotkey_cfg.bind3 = encodeJson(HotkeyCFGKoap:GetHotKey())
    ini.save(settings, 'MVDHelper.ini')
end
    imgui.Text(u8'Остановка /setmark')
    if HotkeyCFGMsm:ShowHotKey() then
    settings.hotkey_cfg.bind4 = encodeJson(HotkeyCFGMsm:GetHotKey())
    ini.save(settings, 'MVDHelper.ini')
end

elseif tab == 4 then
    if imgui.Button(faicons('eject') .. u8' Наш Discord', imgui.ImVec2(145, 30)) then
    os.execute("start https://discord.gg/5KDB5Nww3b")
end
    if imgui.Button(faicons('eject') .. u8' Наш Boosty', imgui.ImVec2(145, 30)) then
    os.execute("start https://boosty.to/andergr0ynd")
        end
    if imgui.Button(faicons('rotate') .. u8' Перезагрузить AHK', imgui.ImVec2(145, 30)) then
    thisScript():reload()
        end
    if imgui.Combo(faicons('palette') .. u8' Темы',colorListNumber,colorListBuffer, #colorList) then
    theme[colorListNumber[0]+1].change()
    settings.color.theme = tostring(colorListNumber[0])
    ini.save(settings, 'MVDHelper')
        end
    end
end
    imgui.End()
end)

imgui.OnFrame(function() return MenuFunction[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(245, 270), imgui.Cond.Always)
    imgui.Begin(u8'MVDHelper | Меню', MenuFunction, imgui.WindowFlags.NoResize)
    imgui.End()
end)

imgui.OnFrame(function() return MenuKoap[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(480, 420), imgui.Cond.Always)
    imgui.Begin(u8'MVDHelper | КоАП', MenuKoap, imgui.WindowFlags.NoResize)
    if imgui.Button(u8'КоАП | 01', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('01 Server')
    end
    if imgui.BeginPopupModal('01 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap01.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 02', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('02 Server')
    end
    if imgui.BeginPopupModal('02 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap02.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    if imgui.Button(u8'КоАП | 03', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('03 Server')
    end
    if imgui.BeginPopupModal('03 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap03.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 04', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('04 Server')
    end
    if imgui.BeginPopupModal('04 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap04.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    if imgui.Button(u8'КоАП | 05', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('05 Server')
    end
    if imgui.BeginPopupModal('05 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap05.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 06', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('06 Server')
    end
    if imgui.BeginPopupModal('06 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap06.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    if imgui.Button(u8'КоАП | 07', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('07 Server')
    end
    if imgui.BeginPopupModal('07 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap07.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 07 | Часть 2', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('07 Server | Часть 2')
    end
    if imgui.BeginPopupModal('07 Server | Часть 2', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap07_2.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    if imgui.Button(u8'КоАП | 08', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('08 Server')
    end
    if imgui.BeginPopupModal('08 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap08.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 09', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('09 Server')
    end
    if imgui.BeginPopupModal('09 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap09.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    if imgui.Button(u8'КоАП | 10', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('10 Server')
    end
    if imgui.BeginPopupModal('10 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap10.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 11', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('11 Server')
    end
    if imgui.BeginPopupModal('11 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap11.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    if imgui.Button(u8'КоАП | 12', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('12 Server')
    end
    if imgui.BeginPopupModal('12 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap12.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 13', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('13 Server')
    end
    if imgui.BeginPopupModal('13 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap13.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    if imgui.Button(u8'КоАП | 14', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('14 Server')
    end
    if imgui.BeginPopupModal('14 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap14.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 15', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('15 Server')
    end
    if imgui.BeginPopupModal('15 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap15.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    if imgui.Button(u8'КоАП | 16', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('16 Server')
    end
    if imgui.BeginPopupModal('16 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap16.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 17', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('17 Server')
    end
    if imgui.BeginPopupModal('17 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap17.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    if imgui.Button(u8'КоАП | 18', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('18 Server')
    end
    if imgui.BeginPopupModal('18 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap18.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 19', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('19 Server')
    end
    if imgui.BeginPopupModal('19 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap19.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    if imgui.Button(u8'КоАП | 20', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('20 Server')
    end
    if imgui.BeginPopupModal('20 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap20.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8'КоАП | 21', imgui.ImVec2(230, 30)) then
	imgui.OpenPopup('21 Server')
    end
    if imgui.BeginPopupModal('21 Server', _, imgui.WindowFlags.NoResize, main_window_state) then
	imgui.SetWindowSizeVec2(imgui.ImVec2(1000, 650))
    local file = io.open(getWorkingDirectory() .. '\\MVDHelper\\koap21.txt', 'r')
    local contents = file:read('*a')
    file:close()
    imgui.TextColoredRGB(u8:decode(contents))
    if imgui.Button(u8'Закрыть', imgui.ImVec2(130, 24)) then
    imgui.CloseCurrentPopup()
    end
    imgui.EndPopup()
    end
    imgui.End()
end)

-- Привязка по нику
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
    sampAddChatMessage('{FF0000}AHK не активирован. Обратитесь в Support за активацией!', -1)
    print('AHK не активирован. Обратитесь в Support за активацией!')
    thisScript():unload()
    end
    if isAvailableUser(users, sampGetPlayerNickname(myid)) then
    sampAddChatMessage('{32CD32}AHK успешно активирован! Можете им пользоваться!', -1)
    print('AHK успешно активирован! Можете им пользоваться!')
    if autoupdate_loaded and enable_autoupdate and Update then
    pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end
    sampRegisterChatCommand('msm', msm)
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
    HotkeyCFGMsm = hotkey.RegisterHotKey('HotkeyCFGMsm', false, decodeJson(settings.hotkey_cfg.bind4), function()
        stop = true
    end)
    while true do
        wait(0)
        if stop then
            stop = false 
            if activate then
                activate = false
                sampAddChatMessage('{006AFF}MVD Helper: {FFFFFF}Слежка остановлена!', -1)
            end
            wait(500)
            end
        end
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


 function msm(arg)
    msm = arg
    if activate then
        activate = false
        sampAddChatMessage('{006AFF}MVD Helper: {FFFFFF}Слежка окончена ID: '..msm, -1)
    else
            if msm:match('%d+') then
                activate = true
        sampAddChatMessage("{006AFF}MVD Helper: {FFFFFF}Начал отслеживать ID: " ..msm, -1)
               
                lua_thread.create(function ()
                    while activate do
                        wait(slider_msm[0] * 1000)
                        sampSendChat('/setmark '..msm)
                    end
                end)
                lua_thread.create(function ()
                    while activate do
                        wait(slider_notification[0] * 1000)
                        sampAddChatMessage('{006AFF}MVD Helper: {FFFFFF}Слежка идёт за: '..msm, -1)
                    end
                end)
            else
        sampAddChatMessage('{006AFF}MVD Helper: {FFFFFF}Похоже, ты не ввел ID...', -1)
            end
        end
    end

-- mimgui style
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
colors[imgui.Col.Text] = imgui.ImVec4(1.0, 0.8, 0.8, 1.0)    
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
colors[imgui.Col.Text] = imgui.ImVec4(0.9, 0.9, 1.0, 1.0)      
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
colors[imgui.Col.Text] = imgui.ImVec4(1.0, 0.8, 1.0, 1.0)     
end
        },
        {
-- белая
change = function()
local style = imgui.GetStyle()
style.WindowRounding = 6
style.FrameRounding = 4
style.PopupRounding = 4
style.GrabRounding = 4
style.ScrollbarRounding = 4
style.WindowBorderSize = 1
local colors = style.Colors
colors[imgui.Col.WindowBg] = imgui.ImVec4(0.9, 0.9, 0.9, 0.95) 
colors[imgui.Col.TitleBg] = imgui.ImVec4(0.8, 0.8, 0.8, 1.0)  
colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.7, 0.7, 0.7, 1.0)
colors[imgui.Col.Border] = imgui.ImVec4(0.6, 0.6, 0.6, 1.0) 
colors[imgui.Col.Button] = imgui.ImVec4(0.7, 0.7, 0.7, 1.0) 
colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.6, 0.6, 0.6, 1.0)
colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.5, 0.5, 0.5, 1.0)
colors[imgui.Col.FrameBg] = imgui.ImVec4(0.85, 0.85, 0.85, 1.0)
colors[imgui.Col.Text] = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
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
colors[imgui.Col.Text] = imgui.ImVec4(0.9, 0.9, 0.9, 1.0)
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
