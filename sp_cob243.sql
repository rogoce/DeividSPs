--Modificado: 25/08/2022 - Autor: HGIRON error-310 tmp_cobcu existe en fisico cambio por tmp_cobcuh
drop procedure sp_cob243;

create procedure "informix".sp_cob243(a_usuario char(8))
returning integer;

define _fecha_time datetime year to fraction(5);

begin

let _fecha_time = CURRENT;
drop table if exists tmp_cobcuh;	

select * 
  from cobcutmp
  into temp tmp_cobcuh;

INSERT INTO cobcutmpbk(
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
FROM tmp_cobcuh;

drop table tmp_cobcuh;

end 
return 0;

end procedure;
