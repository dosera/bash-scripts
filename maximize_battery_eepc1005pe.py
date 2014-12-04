#!/usr/bin/env python

# Maximize the battery runtime, using ArchLinux on an
# Asus EEEPC 1005PE.
# Requires powerdown (https://github.com/march-linux/powerdown).
#
# Written and contributed by
#        Andre Doser <dosera AT gmail.com>
from os import system
from os import popen
import sys
from optparse import OptionParser


class SaveBattery:
    def __init__(self):
        self._audio_driver = 'snd_hda_intel'
        self._audio_codec = 'snd_hda_codec_realtek'
        self._wifi_driver = 'ath9k'

    def call_modprobe_function(self, status, *args):
        """
        Loads/Unloads the given drivers.

        :param status: Load or unload
        :param args: The drivers
        """
        for arg in args:
            system('sudo modprobe {} {}'.format('-r' if status else '', arg))

    def audio_func(self, b):
        """
        Load/Unload the audio driver

        :param b: Load or unload
        """
        self.call_modprobe_function(b, self._audio_driver, self._audio_codec)

    def wifi_func(self, b):
        """
        Load/Unload the wifi driver

        :param b: Load or unload
        """
        self.call_modprobe_funcion(b, self._wifi_driver)
        if b:
            system('sudo systemctl stop wicd')
            system('killall wicd-client')
        else:
            system('sudo systemctl start wicd')
            print("Please start wicd-client to connect to a WIFI network now.")

    def get_driver_status(self, *args):
        """
        Get the status of the drivers and the powerdown script.

        :param args: Drivers to check

        :returns: tuple containg driver status for each driver
                  as well as the status of the powerdown script
        """
        result = []
        for arg in args:
            result.append(True if popen('lsmod | grep {}'.format(arg))
                          .readlines() else False)
        watch_f = '/proc/sys/kernel/nmi_watchdog'
        result.append('Up' if '1' in open(watch_f, 'r').read() else 'Down')
        return tuple(result)

    def powerup(self, watch_status):
        """
        Call the power{down,up} script
        (https://wiki.archlinux.org/index.php/Powerdown)

        :param watch_status: Status of powerdown;
                             'Up' if powerup, 'Down' if powerdown is active
        """
        if 'Up' in watch_status:
            system('sudo /usr/bin/powerdown')
        else:
            system('sudo /usr/bin/powerup')

if __name__ == '__main__':
    sb = SaveBattery()
    # get the status of the drivers
    driver_status_list = sb.get_driver_status('ath9k', 'snd_hda_')
    # initialize the OptionParser
    parser = OptionParser(epilog="Wifi: {}, Audio: {}, Power: {}"
                          .format(*driver_status_list))
    parser.add_option('-w', '--wifi',
                      help='Enables/Disables the wifi device wlp2s0.',
                      dest='wifi', action='store_true')
    parser.add_option('-a', '--audio',
                      help='Enables/Disables the audio device snd_hda_*.',
                      dest='audio', action='store_true')
    parser.add_option('-p', '--power',
                      help='Powerup/-down',
                      dest='power', action='store_true')
    (opts, args) = parser.parse_args()
    # print help if no parameter is passed
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    # wifi
    if opts.wifi:
        sb.wifi_func(driver_status_list[0])
    # audio
    if opts.audio:
        sb.audio_func(driver_status_list[1])
    # power
    if opts.power:
        sb.powerup(driver_status_list[2])
