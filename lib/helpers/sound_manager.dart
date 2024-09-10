import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

AudioController audioController = AudioController();

class AudioController {
  static final Logger _log = Logger('AudioController');
  static late final Box musicBox;

  SoLoud? _soloud;
  SoundHandle? _musicHandle;

  bool isFXMute = false;
  bool isMusicMute = false;
  double maxMusicVolume = 0.0;
  double musicVolume = 0.0;

  final Map<String, AudioSource> _loadedSounds = {};

  Future<void> initialize() async {
    musicBox = await Hive.openBox('level_manager');
    isFXMute = musicBox.get("FX_MUTE", defaultValue: false);
    isMusicMute = musicBox.get("MUSIC_MUTE", defaultValue: false);

    // Load soloud
    _soloud = SoLoud.instance;
    await _soloud!.init();

    // Load soloud related settings
    musicVolume = maxMusicVolume =
        musicBox.get("MUSIC_VOLUME") ?? _soloud!.getGlobalVolume() ?? 0.6;
  }

  void dispose() {
    _soloud?.deinit();
  }

  Future<void> playSound(String assetKey) async {
    if (isFXMute) return;
    AudioSource? source;
    try {
      if (_loadedSounds.containsKey(assetKey)) {
        source = _loadedSounds[assetKey]!;
      } else {
        source = await _soloud!.loadAsset(assetKey);
        _loadedSounds[assetKey] = source;
      }
      await _soloud!.play(source);
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound '$assetKey'. Ignoring.", e);
    }
  }

  Future<void> startMusic(String file, {bool looping = false}) async {
    if (_musicHandle != null) {
      if (_soloud!.getIsValidVoiceHandle(_musicHandle!)) {
        _log.info('Music is already playing. Stopping first.');
        await _soloud!.stop(_musicHandle!);
      }
    }

    AudioSource? musicSource;
    if (_loadedSounds.containsKey(file)) {
      musicSource = _loadedSounds[file]!;
    } else {
      musicSource = await _soloud!.loadAsset(file, mode: LoadMode.disk);
      _loadedSounds[file] = musicSource;
    }

    /* AudioSource? musicSource =
        await _soloud!.loadAsset(file, mode: LoadMode.disk);
    musicSource.allInstancesFinished.first.then((_) async { 
      await _soloud!.disposeSource(musicSource);
      _log.info('Music source disposed');
      _musicHandle = null;
    }); */

    _log.info('Playing music');
    try {
      _musicHandle = await _soloud!
          .play(musicSource, looping: looping, volume: musicVolume);
    } catch (e) {
      print(e);
    }
  }

  void fadeOutMusic() {
    if (_musicHandle == null) {
      _log.info('Nothing to fade out');
      return;
    }
    const length = Duration(seconds: 5);
    _soloud!.fadeVolume(_musicHandle!, 0, length);
    _soloud!.scheduleStop(_musicHandle!, length);
  }

  void muteFX() {
    isFXMute = true;
    musicBox.put("FX_MUTE", isFXMute);
  }

  void unMuteFX() {
    isFXMute = false;
    musicBox.put("FX_MUTE", isFXMute);
  }

  void toggleMuteFX() {
    isFXMute ? unMuteFX() : muteFX();
  }

  void muteMusic() {
    isMusicMute = true;
    musicVolume = 0.0;
    _soloud!.setGlobalVolume(musicVolume);
    musicBox.put("FX_MUTE", isMusicMute);
  }

  void unMuteMusic() {
    isMusicMute = false;
    musicVolume = maxMusicVolume;
    _soloud!.setGlobalVolume(musicVolume);
    musicBox.put("FX_MUTE", isMusicMute);
  }

  void toggleMuteMusic() {
    isFXMute ? unMuteMusic() : muteMusic();
  }
}
