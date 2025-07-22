// NB!: Do not try to use Karabiner with ZMK keyboard as it breaks mod-morphs:
// https://github.com/pqrs-org/Karabiner-Elements/issues/3420

const KB: Keyboards = {
    MacBook: {
        vendor_id: 1452,
        product_id: 835,
    },
}

const DEVICE: DeviceConditions = {
    MacBookKB: {
        type: "device_if",
        identifiers: [KB.MacBook],
    },
}

const MacBookRule: Rule = {
    description: "Macbook keyboard configuration",
    manipulators: [
        {
            type: "basic",
            from: { key_code: "f1" },
            to: [{ consumer_key_code: "display_brightness_decrement" }],
            conditions: [DEVICE.MacBookKB],
        },
        {
            type: "basic",
            from: { key_code: "f2" },
            to: [{ consumer_key_code: "display_brightness_increment" }],
            conditions: [DEVICE.MacBookKB],
        },
        {
            type: "basic",
            from: { key_code: "f7" },
            to: [{ consumer_key_code: "rewind" }],
            conditions: [DEVICE.MacBookKB],
        },
        {
            type: "basic",
            from: { key_code: "f8" },
            to: [{ consumer_key_code: "play_or_pause" }],
            conditions: [DEVICE.MacBookKB],
        },
        {
            type: "basic",
            from: { key_code: "f9" },
            to: [{ consumer_key_code: "fastforward" }],
            conditions: [DEVICE.MacBookKB],
        },
        {
            type: "basic",
            from: { key_code: "f10" },
            to: [{ consumer_key_code: "mute" }],
            conditions: [DEVICE.MacBookKB],
        },
        {
            type: "basic",
            from: { key_code: "f11" },
            to: [{ consumer_key_code: "volume_decrement" }],
            conditions: [DEVICE.MacBookKB],
        },
        {
            type: "basic",
            from: { key_code: "f12" },
            to: [{ consumer_key_code: "volume_increment" }],
            conditions: [DEVICE.MacBookKB],
        },
    ],
}

const ComplexModifications: ComplexModifications = { rules: [MacBookRule] }

// --- Update

import * as fs from "fs"
import * as path from "path"
import { fileURLToPath } from "url"

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const configPath = path.join(__dirname, "karabiner.json")

try {
    const configData = fs.readFileSync(configPath, "utf8")
    const config: KarabinerConfig = JSON.parse(configData)

    config.profiles.forEach((profile) => {
        profile.complex_modifications = ComplexModifications
    })

    fs.writeFileSync(configPath, JSON.stringify(config, null, 4))
    console.log("🟢 Karabiner configuration updated successfully")
    process.exit(0)
} catch (error) {
    console.error("🔴 Error updating Karabiner configuration:", error)
    process.exit(1)
}

// --- Types

type Keyboards = { [key: string]: DeviceIdentifier }
type DeviceConditions = { [key: string]: DeviceCondition }

interface Modifier {
    mandatory?: string[]
    optional?: string[]
}

interface KeyCode {
    key_code: string
    modifiers?: Modifier | string[]
}

interface ConsumerKey {
    consumer_key_code: string
}

interface ToEvent extends Partial<KeyCode>, Partial<ConsumerKey> {
    modifiers?: string[]
}

interface FrontmostApplicationCondition {
    type: "frontmost_application_if" | "frontmost_application_unless"
    file_paths?: string[]
    bundle_identifiers?: string[]
}

interface DeviceIdentifier {
    vendor_id: number
    product_id: number
}

interface DeviceCondition {
    type: "device_if" | "device_unless"
    identifiers: DeviceIdentifier[]
}

type Condition = FrontmostApplicationCondition | DeviceCondition

interface Manipulator {
    type: "basic"
    from: KeyCode
    to: ToEvent[]
    conditions?: Condition[]
}

interface Rule {
    description: string
    manipulators: Manipulator[]
}

interface ComplexModifications {
    rules: Rule[]
}

interface Device {
    identifiers: {
        vendor_id: number
        product_id: number
        is_keyboard?: boolean
        is_pointing_device?: boolean
    }
    ignore?: boolean
    ignore_vendor_events?: boolean
    manipulate_caps_lock_led?: boolean
}

interface Profile {
    name: string
    complex_modifications: ComplexModifications
    devices?: Device[]
    selected?: boolean
    virtual_hid_keyboard?: {
        keyboard_type_v2: string
    }
}

interface KarabinerConfig {
    profiles: Profile[]
}
