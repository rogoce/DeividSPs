-- Anula requisicion de chqchmae especial para contabilidad
-- Creado    : 03/06/2011 - Autor: Henry Giron 
-- SIS v.2.0 - - DEIVID, S.A.

drop procedure sp_che130;
create procedure "informix".sp_che130(a_no_requis char(10),a_user char(10)
) returning integer,char(255);

define _error			integer;
define _fecha           date;
define _cod_auxiliar    char(3);
define _renglon			integer;
define _cod_banco       char(3);
define _cod_chequera	char(3);
define _cuenta_banc     char(25);
define _centro_costo    char(3);
define _no_cheque       integer;
define _cnt             smallint;

LET _fecha = current;
LET _cnt   = 0;

-- return 0,"Proceso de Sistema.";
-- set debug file to "sp_che130.trc";
-- trace on;

begin
on exception set _error
	return _error, "Error al anular requisicion "||trim(a_no_requis);	
end exception

	select cod_banco,
	       cod_chequera,
		   centro_costo,
		   no_cheque
	  into _cod_banco,
	       _cod_chequera,
		   _centro_costo,
		   _no_cheque
	  from chqchmae
	 where no_requis = a_no_requis;

	select count(*)
	  into _cnt
	  from chqchmae
	 where cod_banco    = _cod_banco
	   and cod_chequera = _cod_chequera
	   and no_cheque    = _no_cheque
	   and tipo_requis  = 'C';

    if _cnt > 1 then
		return 1, "Ya Existe Requisicion para el cheque que quiere anular.";
	end if

  	update chqchmae
	   set pagado          = 1,
	       anulado         = 1,
	       fecha_anulado   = _fecha,
	       anulado_por     = a_user,
		   hora_anulado    = current
     where no_requis       = a_no_requis;

	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;

	let _renglon = 0;
	let _cod_auxiliar = null;
	let _renglon = _renglon + 1;

	LET _cuenta_banc = sp_sis15("BACHEQL","02",_cod_banco,_cod_chequera);

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	tipo,
	cuenta,
	debito,
	credito,
	centro_costo,
	cod_auxiliar
	)
	VALUES(
	a_no_requis,
	_renglon,
	"1",
	_cuenta_banc,
	1,
	0,
	_centro_costo,
	_cod_auxiliar
	);

	let _renglon = _renglon + 1;

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	tipo,
	cuenta,
	debito,
	credito,
	centro_costo,
	cod_auxiliar
	)
	VALUES(
	a_no_requis,
	_renglon,
	"2",
	_cuenta_banc,
	0,
	1,
	_centro_costo,
	_cod_auxiliar
	);

	let _renglon = _renglon + 1;

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	tipo,
	cuenta,
	debito,
	credito,
	centro_costo,
	cod_auxiliar
	)
	VALUES(
	a_no_requis,
	_renglon,
	"1",
	_cuenta_banc,
	0,
	1,
	_centro_costo,
	_cod_auxiliar
	);

	let _renglon = _renglon + 1;

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	tipo,
	cuenta,
	debito,
	credito,
	centro_costo,
	cod_auxiliar
	)
	VALUES(
	a_no_requis,
	_renglon,
	"2",
	_cuenta_banc,
	1,
	0,
	_centro_costo,
	_cod_auxiliar
	);

end
return 0, "Actualizacion Exitosa ... Requisicion "||trim(a_no_requis)||" Anulada.";
end procedure			 








