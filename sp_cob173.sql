-- Procedimiento que Genera la Remesa de los Pagos Externos

-- Creado    : 27/10/2004 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob173;

create procedure "informix".sp_cob173()

define _numero			char(10);
define _renglon			smallint;
define _no_documento	char(20);
define _no_poliza		char(10);

create temp table tmp_numero(
numero	char(10),
renglon smallint
) with no log;

foreach
 select numero,
        renglon,
		no_documento
   into _numero,
        _renglon,
		_no_documento
   from cobpaex1
  order by 1, 2

	let _no_poliza = sp_sis21(_no_documento);

	if _no_poliza is null then

		insert into tmp_numero
		values (_numero, _renglon);

  	end if

end foreach

select c.*
  from cobpaex1 c, tmp_numero n
 where c.numero  = n.numero
   and c.renglon = n.renglon
  into temp tmp_ducruet;

drop table tmp_numero;

end procedure