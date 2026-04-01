-- Reporte para las requisiciones de Reclamos de Salud	en firma

-- Creado    : 12/07/2006 - Autor: Armando Moreno

drop procedure sp_che55a;

create procedure sp_che55a()
 returning char(8),
		   integer,
		   integer;

define _firma1			char(8);
define _firma2			char(8);
define _cantidad        integer;
define _cantidad2       integer;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _fecha_captura   date;

CREATE TEMP TABLE tmp_pr(
		usuario		CHAR(8),
		cant1		integer,
		cant2		integer,
        PRIMARY KEY (usuario))
		WITH NO LOG;

SET ISOLATION TO DIRTY READ;

select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

foreach
 select	firma1
   into	_firma1
   from	chqchmae
  where anulado       = 0
	and cod_banco     = _cod_banco
	and cod_chequera  = _cod_chequera
	and en_firma      = 1

BEGIN
     ON EXCEPTION IN(-239)
        UPDATE tmp_pr
           SET cant1 = cant1 + 1
         WHERE usuario = _firma1;
     END EXCEPTION

	if _firma1 is null then
		let _firma1 = "";
	end if

	INSERT INTO tmp_pr(
	usuario,
	cant1,
	cant2
	)
	VALUES(
	_firma1,
	1,
	0
	);

END

end foreach

foreach
 select	firma2,
        firma1
   into	_firma2,
        _firma1
   from	chqchmae
  where anulado       = 0
	and cod_banco     = _cod_banco
	and cod_chequera  = _cod_chequera
	and en_firma      = 1

BEGIN
     ON EXCEPTION IN(-239)
        UPDATE tmp_pr
           SET cant2 = cant2 + 1
         WHERE usuario = _firma2;
     END EXCEPTION


	if _firma1 is not null and _firma2 is null then
		let _firma2 = 'DIRECTOR';
	end if

	if _firma1 is null and _firma2 is null then
		let _firma2 = "";
	end if

	INSERT INTO tmp_pr(
	usuario,
	cant2,
	cant1
	)
	VALUES(
	_firma2,
	1,
	0
	);

END

end foreach

FOREACH
 SELECT usuario,
		cant1,
		cant2
   INTO _firma1,
		_cantidad,
		_cantidad2
   FROM tmp_pr
  ORDER BY 1

	RETURN _firma1,			
		   _cantidad,
		   _cantidad2
		   WITH RESUME;	 		

END FOREACH;

DROP TABLE tmp_pr;

end procedure
