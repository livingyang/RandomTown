describe "HeroFightSpec", ->
	it "生成攻击数据", ->
		attacker =
			attack: 100
			defense: 80
			health: 120

		defenser =
			attack: 100
			defense: 70
			health: 40

		heroFight = new HeroFight
			attacker: attacker
			defenser: defenser
			maxTurnCount: 100

		expect(heroFight.maxTurnCount).toBe(100)
		expect(heroFight.attacker.attack).toBe(100)
		expect(heroFight.attacker.defense).toBe(80)
		expect(heroFight.defenser.attack).toBe(100)
		expect(heroFight.defenser.defense).toBe(70)

		expect(heroFight.attacker.health).toBe(100)
		expect(heroFight.defenser.health).toBe(-20)

		expect(attacker.health).toBe(120)
		expect(defenser.health).toBe(40)

