pragma Singleton

import Quickshell

Singleton {
    id: root

    function getNetworkIcon(strength: int): string {
        if (strength >= 80)
            return "signal_wifi_4_bar";
        if (strength >= 60)
            return "network_wifi_3_bar";
        if (strength >= 40)
            return "network_wifi_2_bar";
        if (strength >= 20)
            return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    function getVolumeIcon(volume: real, isMuted: bool): string {
        if (isMuted)
            return "volume_off";
        if (volume >= 0.3)
            return "volume_up";
        if (volume > 0)
            return "volume_down";
        return "volume_mute";
    }

    function getNotificationIcon(isSilent: bool): string {
        if (isSilent)
            return "Notifications_Paused";

        return "Notifications";
    }

    function getBrightnessIcon(value: real): string {
        if (value >= 0.65)
            return "brightness_high";
        if (value >= 0.35)
            return "brightness_medium";
        if (value > 0)
            return "brightness_low";
        return "brightness_empty";
    }
}
