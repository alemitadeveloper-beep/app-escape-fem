class Avatar {
  final String id;
  final String emoji;
  final String name;

  const Avatar({
    required this.id,
    required this.emoji,
    required this.name,
  });

  // Lista de avatares predefinidos
  static const List<Avatar> predefinedAvatars = [
    Avatar(id: 'detective', emoji: '🕵️', name: 'Detective'),
    Avatar(id: 'spy', emoji: '🕴️', name: 'Espía'),
    Avatar(id: 'ninja', emoji: '🥷', name: 'Ninja'),
    Avatar(id: 'scientist', emoji: '👩‍🔬', name: 'Científica'),
    Avatar(id: 'adventurer', emoji: '🧗', name: 'Aventurera'),
    Avatar(id: 'explorer', emoji: '🧭', name: 'Exploradora'),
    Avatar(id: 'wizard', emoji: '🧙', name: 'Maga'),
    Avatar(id: 'hero', emoji: '🦸', name: 'Heroína'),
    Avatar(id: 'pirate', emoji: '🏴‍☠️', name: 'Pirata'),
    Avatar(id: 'astronaut', emoji: '👩‍🚀', name: 'Astronauta'),
    Avatar(id: 'artist', emoji: '👩‍🎨', name: 'Artista'),
    Avatar(id: 'police', emoji: '👮', name: 'Policía'),
    Avatar(id: 'ghost', emoji: '👻', name: 'Fantasma'),
    Avatar(id: 'zombie', emoji: '🧟', name: 'Zombie'),
    Avatar(id: 'vampire', emoji: '🧛', name: 'Vampira'),
    Avatar(id: 'alien', emoji: '👽', name: 'Alien'),
    Avatar(id: 'robot', emoji: '🤖', name: 'Robot'),
    Avatar(id: 'clown', emoji: '🤡', name: 'Payasa'),
    Avatar(id: 'crown', emoji: '👑', name: 'Reina'),
    Avatar(id: 'key', emoji: '🔑', name: 'Llave'),
  ];

  static Avatar? findById(String id) {
    try {
      return predefinedAvatars.firstWhere((avatar) => avatar.id == id);
    } catch (e) {
      return null;
    }
  }

  static Avatar get defaultAvatar => predefinedAvatars[0]; // Detective por defecto
}
