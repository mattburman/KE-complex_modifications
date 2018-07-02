#!/usr/bin/env ruby

require 'json'

$apps_trigger_key = 'o'
$searches_trigger_key = 's'
$simultaneous_threshold_milliseconds = 250


def main
    $app_launchers = [
        ["2", "open -a '2Do.app'"],
        ["a", "open -a 'Activity Monitor.app'"],
        ["c", "open -a 'Fantastical 2.app'"],
        ["g", "open -a 'Google Chrome.app'"],
        ["s", "open -a 'Visual Studio Code.app'"],
        ["f", "open -a 'Finder.app'"],
        ["i", "open -a 'iTerm.app'"],
        ["m", "open -a 'Chatty.app'"],
        ["p", "open -a 'Pocket.app'"],
        ["q", "open -a 'PyCharm.app'"],
        ["r", "open -a 'Reeder.app'"],
        ["t", "open -a 'TweetDeck.app'"],
        ["v", "open -a 'PDF Expert.app'"],
        ["w", "open -a 'WhatsApp.app'"],
        ["e", "open -a 'Airmail 3.app'"],
        ["l", "open -a 'LastPass.app'"],
        ["b", "open -a 'Safari.app'"],
        ["d", "open -a 'Day One.app'"],
        ["h", "open -a 'Spotify.app'"],
        ["j", "open -a 'WebStorm.app'"],
        ["k", "open -a 'Keyboard Maestro.app'"],
        ["x", "open -a 'Karabiner-Elements.app'"],
    ].collect { |arr| generate_launcher_mode(arr[0], [], [ { "shell_command" => arr[1] }], $apps_trigger_key) }
    .push(
        generate_launcher_mode("tab", [], [ { "key_code" => "mission_control" } ], $apps_trigger_key),
        generate_launcher_mode("u", [], [ { "key_code" => "f4" } ], $apps_trigger_key),
        generate_launcher_mode("spacebar", [], [ { "shell_command" => "open -a 'Alfred 3.app'" } ], $apps_trigger_key),
    )
    $search_launchers = [
        ["k", "menubarsearch", "com.folded-paper.menu-bar-search", ""],
        ["g", "github", "de.gh01.alfred.github", ""],
        ["y", "youtube", "net.deanishe.alfred-searchio", ""],
        ["i", "iterm", "com.madvas.iterm-sessions", ""],
        ["o", "googlesearch", "io.github.ethan-funny", ""]
    ].collect { |arr|
      generate_launcher_mode(
        arr[0],
        [],
        [ { "shell_command" =>
          "osascript -e 'tell application \"Alfred 3\" to run trigger \"#{arr[1]}\" in workflow \"#{arr[2]}\" with argument \"#{arr[3]}\"'"
        }],
        $searches_trigger_key
      )
  }.push(
    generate_launcher_mode(
      "l", [],
      [ { "key_code": "z", "modifiers": ["left_shift", "left_command", "left_option", "left_control"]}],
      $searches_trigger_key
    ),
    generate_launcher_mode(
      "e", [],
      [ { "key_code": "e", "modifiers": ["left_shift", "left_command", "left_option", "left_control"]}],
      $searches_trigger_key
    )
  )
    puts JSON.pretty_generate({
        "title" => "Personal rules (@mattburman)",
        "rules" => [
            {
                "description" => "Launcher Mode v4 (rev 2) [@mattburman]",
                "manipulators" => $app_launchers.flatten
            },
            {
              "description" => "Searches Launcher Mode v4 (rev 2) [@mattburman]",
              "manipulators" => $search_launchers.flatten
            },
            {
                "description" => "Mouse Keys Mode v4 (rev 1) [@mattburman:ESCAPE]",
                "manipulators" => [
                    # hjkl
                    generate_mouse_keys_mode("j",
                                                [ { "mouse_key" => { "y" => 1536, }, }, ],
                                                [ { "mouse_key" => { "vertical_wheel" => 32, }, }, ],
                                                nil,
                                                $simultaneous_threshold_milliseconds),
                    generate_mouse_keys_mode("k",
                                                [ { "mouse_key" => { "y" => -1536, }, }, ],
                                                [ { "mouse_key" => { "vertical_wheel" => -32, }, }, ],
                                                nil,
                                                $simultaneous_threshold_milliseconds),
                    generate_mouse_keys_mode("h",
                                                [ { "mouse_key" => { "x" => -1536, }, }, ],
                                                [ { "mouse_key" => { "horizontal_wheel" => 32, }, }, ],
                                                nil,
                                                $simultaneous_threshold_milliseconds),
                    generate_mouse_keys_mode("l",
                                                [ { "mouse_key" => { "x" =>  1536, }, }, ],
                                                [ { "mouse_key" => { "horizontal_wheel" => -32, }, }, ],
                                                nil,
                                                $simultaneous_threshold_milliseconds),

                    # buttons
                    generate_mouse_keys_mode("v",
                                                [ { "pointing_button" => "button1", }, ],
                                                nil,
                                                nil,
                                                $simultaneous_threshold_milliseconds),
                    generate_mouse_keys_mode("b",
                                                [ { "pointing_button" => "button3", }, ],
                                                nil,
                                                nil,
                                                $simultaneous_threshold_milliseconds),
                    generate_mouse_keys_mode("n",
                                                [ { "pointing_button" => "button2", }, ],
                                                nil,
                                                nil,
                                                $simultaneous_threshold_milliseconds),

                # others
                generate_mouse_keys_mode("s",
                                            [ { "set_variable" => { "name" => "mouse_keys_mode_v4_scroll", "value" => 1, }, }, ],
                                            nil,
                                            [ { "set_variable" => { "name" => "mouse_keys_mode_v4_scroll", "value" => 0, }, }, ],
                                            $simultaneous_threshold_milliseconds),
                generate_mouse_keys_mode("f",
                                            [ { "mouse_key" => { "speed_multiplier" => 2.0 } }, ],
                                            nil,
                                            nil,
                                            $simultaneous_threshold_milliseconds),
                generate_mouse_keys_mode("g",
                                            [ { "mouse_key" => { "speed_multiplier" => 0.5 } }, ],
                                            nil,
                                            nil,
                                            $simultaneous_threshold_milliseconds),
                ].flatten,
            }
        ]
    })
end

def generate_launcher_mode(from_key_code, mandatory_modifiers, to, trigger_key)
  data = []

  ############################################################

  h = {
    "type" => "basic",
    "from" => {
      "key_code" => from_key_code,
      "modifiers" => {
        "mandatory" => mandatory_modifiers,
        "optional" => [
          "any",
        ],
      },
    },
    "to" => to,
    "conditions" => [
      {
        "type" => "variable_if",
        "name" => "launcher_mode_v4",
        "value" => 1,
      },
    ],
  }

  data << h

  ############################################################

  h = {
    "type" => "basic",
    "from" => {
      "simultaneous" => [
        {
          "key_code" => trigger_key,
        },
        {
          "key_code" => from_key_code,
        },
      ],
      "simultaneous_options" => {
        "key_down_order" => "strict",
        "key_up_order" => "strict_inverse",
        "to_after_key_up" => [
          {
            "set_variable" => {
              "name" => "launcher_mode_v4",
              "value" => 0,
            },
          },
        ],
      },
      "modifiers" => {
        "mandatory" => mandatory_modifiers,
        "optional" => [
          "any",
        ],
      },
    },
    "to" => [
      {
        "set_variable" => {
          "name" => "launcher_mode_v4",
          "value" => 1,
        },
      },
    ].concat(to),
    "parameters" => {
      "basic.simultaneous_threshold_milliseconds" => $simultaneous_threshold_milliseconds,
    },
  }

  data << h

  ############################################################

  data
end

def generate_mouse_keys_mode(from_key_code, to, scroll_to, to_after_key_up, simultaneous_threshold_milliseconds)
  data = []

  ############################################################

  unless scroll_to.nil?
    h = {
      "type" => "basic",
      "from" => {
        "key_code" => from_key_code,
        "modifiers" => {
          "optional" => [
            "any",
          ],
        },
      },
      "to" => scroll_to,
      "conditions" => [
        {
          "type" => "variable_if",
          "name" => "mouse_keys_mode_v4",
          "value" => 1,
        },
        {
          "type" => "variable_if",
          "name" => "mouse_keys_mode_v4_scroll",
          "value" => 1,
        }
      ],
    }

    unless to_after_key_up.nil?
      h["to_after_key_up"] = to_after_key_up
    end

    data << h
  end

  ############################################################

  h = {
    "type" => "basic",
    "from" => {
      "key_code" => from_key_code,
      "modifiers" => {
        "optional" => [
          "any",
        ],
      },
    },
    "to" => to,
    "conditions" => [
      {
        "type" => "variable_if",
        "name" => "mouse_keys_mode_v4",
        "value" => 1,
      }
    ],
  }

  unless to_after_key_up.nil?
    h["to_after_key_up"] = to_after_key_up
  end

  data << h

  ############################################################

  h = {
    "type" => "basic",
    "from" => {
      "simultaneous" => [
        {
          "key_code" => "escape",
        },
        {
          "key_code" => from_key_code,
        },
      ],
      "simultaneous_options" => {
        "key_down_order" => "strict",
        "key_up_order" => "strict_inverse",
        "to_after_key_up" => [
          {
            "set_variable" => {
              "name" => "mouse_keys_mode_v4",
              "value" => 0,
            },
          },
          {
            "set_variable" => {
              "name" => "mouse_keys_mode_v4_scroll",
              "value" => 0,
            },
          },
        ],
      },
      "modifiers" => {
        "optional" => [
          "any",
        ],
      },
    },
    "to" => [
      {
        "set_variable" => {
          "name" => "mouse_keys_mode_v4",
          "value" => 1,
        },
      },
    ].concat(to),
    "parameters" => {
      "basic.simultaneous_threshold_milliseconds" => simultaneous_threshold_milliseconds,
    },
  }

  unless to_after_key_up.nil?
    h["to_after_key_up"] = to_after_key_up
  end

  data << h

  ############################################################

  data
end

main()