class ShadowcraftOptions
  @buffMap = [
    'short_term_haste_buff',
    'stat_multiplier_buff',
    'crit_chance_buff',
    'mastery_buff',
    'melee_haste_buff',
    'attack_power_buff',
    'armor_debuff',
    'physical_vulnerability_debuff',
    'spell_damage_debuff',
    'agi_flask_mop',
    'food_300_agi'
  ]

  cast = (val, dtype) ->
    switch dtype
      when "integer"
        val = parseInt(val, 10)
        val = 0 if isNaN(val)
      when "float"
        val = parseFloat(val, 10)
        val = 0 if isNaN(val)
      when "bool"
        val = val == true or val == "true" or val == 1
    val

  enforceBounds = (val, mn, mx) ->
    if typeof(val) == "number"
      if mn and val < mn
        val = mn
      else if mx and val > mx
        val = mx
    else
      return val
    val

  setup: (selector, namespace, checkData) ->
    data = Shadowcraft.Data
    s = $(selector);
    for key, opt of checkData
      ns = data.options[namespace]
      val = null
      if !ns
        data.options[namespace] = {}
        ns = data.options[namespace]
      if data.options[namespace][key]?
        val = data.options[namespace][key]
      if val == null and opt.default?
        val = opt.default

      val = cast(val, opt.datatype)
      val = enforceBounds(val, opt.min, opt.max)
      data.options[namespace][key] = val

      exist = s.find("#opt-" + namespace + "-" + key)

      inputType = "check"
      if typeof(opt) == "object" and opt.type?
        inputType = opt.type

      if exist.length == 0
        switch inputType
          when "check"
            template = Templates.checkbox
            options =
              label: if typeof(opt) == "string" then opt else opt.name
          when "select"
            template = Templates.select
            templateOptions = []
            if opt.options instanceof Array
              for _v in opt.options
                templateOptions.push {name: _v, value: _v}
            else
              for _k, _v of opt.options
                templateOptions.push {name: _v, value: _k}
            options =
              options: templateOptions
          when "input"
            template = Templates.input
            options = {}
        if template
          s.append template($.extend({
            key: key
            label: opt.name
            namespace: namespace
            desc: opt.desc
          }, options))

        exist = s.find("#opt-" + namespace + "-" + key)
        e0 = exist.get(0)
        $.data(e0, "datatype", opt.datatype)
        $.data(e0, "min", opt.min)
        $.data(e0, "max", opt.max)
      
      switch inputType
        when "check"
          exist.attr("checked", val)
          exist.val(val)
        when "select", "input"
          exist.val(val)

    null

  initOptions: ->
    data = Shadowcraft.Data

    @setup("#settings #general", "general", {
      patch: {type: "select", name: "Patch/Engine", desc: 'Only changes UI Stuff like Talents. It always uses the latest Engine, so you cannot compare Patches.', 'default': 52, datatype: 'integer', options: {50: '5.1', 52: '5.2'}},
      level: {type: "input", name: "Level", 'default': 90, datatype: 'integer', min: 85, max: 90},
      race: {type: "select", options: ["Human", "Dwarf", "Orc", "Blood Elf", "Gnome", "Worgen", "Troll", "Night Elf", "Undead", "Goblin", "Pandaren"], name: "Race", 'default': "Human"}
      duration: {type: "input", name: "Fight Duration", 'default': 360, datatype: 'integer', min: 15, max: 1200}
      response_time: {type: "input", name: "Response Time", 'default': 0.5, datatype: 'float', min: 0.1, max: 5}
      time_in_execute_range: {type: "input", name: "Time in Execute Range", desc: "Only working with Assassination", 'default': 0.35, datatype: 'float', min: 0, max: 1}
      lethal_poison: {name: "Lethal Poison", type: 'select', options: {'dp': 'Deadly Poison', 'wp': 'Wound Poison'}, 'default': 'dp'}
      utility_poison: {name: "Utility Poison", type: 'select', options: {'lp': 'Leeching Poison', 'n': 'Other/None'}, 'default': 'lp'}
      max_ilvl: {name: "Max ILevel", type: "input", desc: "Don't show items over this ilevel in gear lists", 'default': 600, datatype: 'integer', min: 15, max: 600}
      min_ilvl: {name: "Min ILevel", type: "input", desc: "Don't show items under this ilevel in gear lists", 'default': 430, datatype: 'integer', min: 15, max: 600},
      epic_gems: {name: "Recommend Epic Gems", datatype: 'integer', type: 'select', options: {1: 'Yes', 0: 'No'}}
      show_upgrades: {name: "Show Upgrades", desc: "Show all upgraded items on ranking", datatype: 'integer', type: 'select', options: {1: 'Yes', 0: 'No'}, 'default': 0}
      show_random_items: {name: "Show Random Items", desc: "Show all items with random stats on ranking (Scenario Loot)", datatype: 'integer', type: 'select', options: {1: 'Yes', 0: 'No'}, 'default': 0}
    })

    @setup("#settings #professions", "professions", {
      alchemy:        {'default': false, datatype: 'bool', name: "Alchemy"}
      blacksmithing:  {'default': false, datatype: 'bool', name: "Blacksmithing"}
      enchanting:     {'default': false, datatype: 'bool', name: "Enchanting"}
      engineering:    {'default': false, datatype: 'bool', name: "Engineering"}
      herbalism:      {'default': false, datatype: 'bool', name: "Herbalism"}
      inscription:    {'default': false, datatype: 'bool', name: "Inscription"}
      jewelcrafting:  {'default': false, datatype: 'bool', name: "Jewelcrafting"}
      leatherworking: {'default': false, datatype: 'bool', name: "Leatherworking"}
      mining:         {'default': false, datatype: 'bool', name: "Mining"}
      skinning:       {'default': false, datatype: 'bool', name: "Skinning"}
      tailoring:      {'default': false, datatype: 'bool', name: "Tailoring"}
    })

    @setup("#settings #playerBuffs", "buffs", {
      food_300_agi: {name: "Food Buff", desc: "300 Agi Food", 'default': true, datatype: 'bool'},
      agi_flask_mop: {name: "Agility Flask", desc: "Mists Flask", 'default': true, datatype: 'bool'},
      short_term_haste_buff: {name: "+30% Haste/40 sec", desc: "Heroism/Bloodlust/Time Warp", 'default': true, datatype: 'bool'},
      stat_multiplier_buff: {name: "5% All Stats", desc: "Blessing of Kings/Mark of the Wild/Legacy of the Emperor", 'default': true, datatype: 'bool'},
      crit_chance_buff: {name: "5% Crit", desc: "Leader of the Pack/Arcane Brilliance/Legacy of the White Tiger", 'default': true, datatype: 'bool'},
      melee_haste_buff: {name: "10% Haste", desc: "Unleashed Rage/Unholy Aura/Swiftblade's Cunning", 'default': true, datatype: 'bool'},
      attack_power_buff: {name: "10% Attack Power", desc: "Horn of Winter/Trueshot Aura/Battle Shout", 'default': true, datatype: 'bool'},
      mastery_buff: {name: "Mastery", desc: "Blessing of Might/Grace of Air", 'default': true, datatype: 'bool'}
    })

    @setup("#settings #targetDebuffs", "buffs", {
      armor_debuff: {name: "-12% Armor", desc: "Weakened Armor/Sunder Armor/Faerie Fire/Expose Armor", 'default': true, datatype: 'bool'},
      physical_vulnerability_debuff: {name: "+4% Physical Damage", desc: "Brittle Bones/Colossus Smash/Judgments of the Bold/Ebon Plaguebringer", 'default': true, datatype: 'bool'},
      spell_damage_debuff: {name: "+5% Spell Damage", desc: "Curse of the Elements/Master Poisoner", 'default': true, datatype: 'bool'},
    })

    @setup("#settings #raidOther", "general", {
      prepot: {type: "check", name: "Pre-pot (Virmen's Bite)", 'default': false, datatype: 'bool'},
      virmens_bite: {type: "check", name: "Combat potion (Virmen's Bite)", 'default': true, datatype: 'bool'},
      tricks: {type: "check", name: "Tricks of the Trade on cooldown", 'default': false, datatype: 'bool'},
      receive_tricks: {type: "check", name: "Receiving Tricks on cooldown from another rogue", 'default': false, datatype: 'bool'},
      stormlash: {type: "check", name: "Stormlash Totem", desc: "10sec / 5min cooldown", 'default': false, datatype: 'bool'},
      pvp: {type: "check", name: "PvP Mode", desc: "This actives the PvP Mode (Not fully supported)", 'default': false, datatype: 'bool'},
      #pvp_target_armor: {type: "input", name: "bla", desc: "blllaaa", 'default': 10000, datatype: 'integer', min: 3000, max: 99000},
    })

    @setup("#settings section.mutilate .settings", "rotation", {
      min_envenom_size_non_execute: {type: "select", name: "Min CP/Envenom > 35%", options: [5,4,3,2,1], 'default': 4, desc: "CP for Envenom when using Mutilate, no effect with Anticipation", datatype: 'integer', min: 1, max: 5}
      min_envenom_size_execute: {type: "select", name: "Min CP/Envenom < 35%", options: [5,4,3,2,1], 'default': 5, desc: "CP for Envenom when using Dispatch, no effect with Anticipation", datatype: 'integer', min: 1, max: 5}
      prioritize_rupture_uptime_non_execute: {type: "check", name: "Prioritize Rupture (>35%)", right: true, desc: "Prioritize Rupture over Envenom when your CP builder is Mutilate", default: true, datatype: 'bool'}
      prioritize_rupture_uptime_execute: {type: "check", name: "Prioritize Rupture (<35%)", right: true, desc: "Prioritize Rupture over Envenom when your CP builder is Dispatch", default: true, datatype: 'bool'}
      opener_name_assassination: {type: "select", name: "Opener Name", options: {'mutilate': "Mutilate", 'ambush': "Ambush", 'garrote': "Garrote"}, 'default': 'mutilate', datatype: 'string'}
      opener_use_assassination: {type: "select", name: "Opener Usage", options: {'always': "Always", 'opener': "Start of the Fight", 'never': "Never"}, 'default': 'always', datatype: 'string'}
    })

    @setup("#settings section.combat .settings", "rotation", {
      use_rupture: {type: "check", name: "Use Rupture?", right: true, default: true}
      ksp_immediately: {type: "select", name: "Killing Spree", options: {'true': "Killing Spree on cooldown", 'false': "Wait for Bandit's Guile before using Killing Spree"}, 'default': 'true', datatype: 'string'}
      revealing_strike_pooling: {type: "check", name: "Pool for Revealing Strike", right: true, default: true, datatype: 'bool'}
      stack_cds: {type: "check", name: "Stack Cooldowns", desc: "Use Adrenaline Rush and Shadow Blades together", right: true, default: true, datatype: 'bool'}
      blade_flurry: {type: "check", name: "Blade Flurry", right: true, desc: "Use Blade Flurry", default: false, datatype: 'bool'}
      bf_targets: {type: "select", name: "Blade Flurry Targets", options: [1,2,3,4], 'default': 1, datatype: 'integer', min: 1, max: 4}
      opener_name_combat: {type: "select", name: "Opener Name", options: {'sinister_strike': "Sinister Strike", 'revealing_strike': "Revealing Strike", 'ambush': "Ambush", 'garrote': "Garrote"}, 'default': 'sinister_strike', datatype: 'string'}
      opener_use_combat: {type: "select", name: "Opener Usage", options: {'always': "Always", 'opener': "Start of the Fight", 'never': "Never"}, 'default': 'always', datatype: 'string'}
    })

    @setup("#settings section.subtlety .settings", "rotation", {
      use_hemorrhage: {type: "select", name: "CP Builder", options: {'never': "Backstab", 'always': "Hemorrhage", '24': "Use Backstab and apply Hemorrhage every 24sec"}, default: '24', datatype: 'string'}
      opener_name_subtlety: {type: "select", name: "Opener Name", options: {'ambush': "Ambush", 'garrote': "Garrote"}, 'default': 'ambush', datatype: 'string'}
      opener_use_subtlety: {type: "select", name: "Opener Usage", options: {'always': "Always", 'opener': "Start of the Fight", 'never': "Never"}, 'default': 'always', datatype: 'string'}
    })

    @setup("#advanced #advancedReforge", "advanced", {
      mh_expertise_rating_override: {name: "Custom MH Exp Rating", type: "input", desc: "Override MH expertise rating EP value", 'default': 0.7, datatype: 'float', min: 0.1, max: 5.0}
      oh_expertise_rating_override: {name: "Custom OH Exp Rating", type: "input", desc: "Override OH expertise rating EP value", 'default': 0.3, datatype: 'float', min: 0.1, max: 5.0}
    })

  changeOption = (elem, inputType, val) ->
    $this = $(elem)
    data = Shadowcraft.Data
    ns = elem.attr("data-ns") || "root"
    data.options[ns] ||= {}
    name = $this.attr("name")
    if val == undefined
      val = $this.val()
    t0 = $this.get(0)
    dtype = $.data(t0, "datatype")
    min = $.data(t0, "min")
    max = $.data(t0, "max")
    val = enforceBounds(cast(val, dtype), min, max)
    if $this.val() != val
      $this.val(val)
    if inputType == "check"
      $this.attr("checked", val)

    data.options[ns][name] = val
    Shadowcraft.Options.trigger("update", ns + "." + name, val)
    Shadowcraft.update()

  changeCheck = ->
    $this = $(this)
    changeOption($this, "check", not $this.attr("checked")?)
    Shadowcraft.setupLabels("#settings,#advanced")

  changeSelect = ->
    changeOption(this, "select")

  changeInput = ->
    changeOption(this, "input")

  boot: ->
    app = this
    @initOptions()

    Shadowcraft.bind "loadData", ->
      app.initOptions()
      Shadowcraft.setupLabels("#settings,#advanced")
      $("#settings,#advanced select").change()

    Shadowcraft.Talents.bind "changed", ->
      $("#settings section.mutilate, #settings section.combat, #settings section.subtlety").hide()
      if Shadowcraft.Data.activeSpec == "a"
        $("#settings section.mutilate").show()
      else if Shadowcraft.Data.activeSpec == "Z"
        $("#settings section.combat").show()
      else
        $("#settings section.subtlety").show()

    this

  constructor: ->
    $("#settings,#advanced").bind "change", $.delegate({ ".optionCheck": changeCheck })
    $("#settings,#advanced").bind "change", $.delegate({ ".optionSelect": changeSelect })
    $("#settings,#advanced").bind "change", $.delegate({ ".optionInput": changeInput })
    _.extend(this, Backbone.Events)
