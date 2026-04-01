drop procedure sp_cob244;

create procedure sp_cob244(a_usuario char(8))
returning integer;

define _fecha_time datetime year to fraction(5);

begin

let _fecha_time = CURRENT;

select * 
  from cobcutmp
 where rechazado = 1
  into temp tmp_cobc;

INSERT INTO cobcutmpre(
no_tran,
no_cuenta,
cod_pagador,
motivo,
nombre_pagador,
monto,
cargo,
rechazado,
periodo,
motivo_rechazo,
no_lote,
no_documento,
date_added,
user_added
)
SELECT
no_tran,
no_cuenta,
cod_pagador,
motivo,
nombre_pagador,
monto,
cargo,
rechazado,
periodo,
motivo_rechazo,
no_lote,
no_documento,
_fecha_time,
a_usuario
FROM tmp_cobc;

drop table tmp_cobc;

end 
return 0;

end procedure;
