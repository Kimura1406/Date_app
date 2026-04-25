DELETE FROM chat_messages
WHERE room_id = 'user-281LINAQ-472MARYA'
   OR id IN ('msg_seed_005', 'msg_seed_006');

DELETE FROM chat_room_reads
WHERE room_id = 'user-281LINAQ-472MARYA';

DELETE FROM chat_rooms
WHERE id = 'user-281LINAQ-472MARYA'
  AND room_type = 'user';
