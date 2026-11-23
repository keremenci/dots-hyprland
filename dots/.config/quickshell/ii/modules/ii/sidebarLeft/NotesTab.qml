import QtQuick
import qs.modules.ii.overlay.notes

/**
 * Notes tab: the overlay's notes widget (same ~/.local/state/quickshell/user/notes.txt).
 */
Item {
    id: root

    onFocusChanged: focus => {
        if (focus) notes.focusAtEnd();
    }

    NotesContent {
        id: notes
        anchors.fill: parent
        color: "transparent"
    }
}
