import 'playback_test.dart' as playback;
import 'playlist_test.dart' as playlist;
import 'shuffle_repeat_test.dart' as shuffle_repeat;
import 'permission_test.dart' as permission;
import 'edge_cases_test.dart' as edge_cases;

void main() {
  playback.main();
  playlist.main();  
  shuffle_repeat.main();
  permission.main();
  edge_cases.main();
}