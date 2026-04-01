-- Reporte para las requisiciones de Reclamos de Salud	en firma

-- Creado    : 12/07/2006 - Autor: Armando Moreno

--drop procedure sp_che58a;

create procedure sp_che58a(a_cod_asignacion char(10))
 returning integer,
		   integer;

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _nom_recla		char(100);
define _nom_aseg		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _cod_asegurado	char(10);
define _cod_reclamante	char(10);
define _no_reclamo		char(10);
define _monto_tran		dec(16,2);
define _fecha			date;
define _transaccion		char(10);
define _reclamo			char(18);
define _cant,_saber,_saber2 integer;

SET ISOLATION TO DIRTY READ;

select count(*)
  into _saber
  from rectrmae
 where cod_asignacion = a_cod_asignacion;

let _cant = 0;

if _saber > 0 then		--tiene n/t

	foreach
		select no_requis
		  into _no_requis
		  from rectrmae
		 where cod_asignacion = a_cod_asignacion

		 select	count(*)
		   into	_saber2
		   from	chqchmae
		  where anulado       = 0
		    and autorizado    = 1
			and en_firma      in(1,0)
			and pagado        = 0
			and no_requis     = _no_requis;

		 if _saber2 > 0 then
			let _cant = 1;
		 end if
	   
	end foreach

	return 1,_cant;	
else
	return 0,0;	
end if
end procedure
