--------------------------------------------
--sp_rea34 Movimiento mensual de provision de reaseguro por auxiliar
--execute procedure sp_rea34('2016-11','2550101')
--22/07/2016 - Autor: Román Gordón.
--------------------------------------------
drop procedure sp_rea34;
create procedure sp_rea34(a_periodo char(7), a_cuenta varchar(30))
returning	smallint	as Tipo_registro,
			char(5)		as Cod_Auxiliar,
			varchar(50)	as Auxiliar,
			varchar(50)	as Ramo,
			char(8)		as Comprobante,
			date		as Fechatrx,
			varchar(50)	as Descripcion,
			dec(16,2)	as Db_auxiliar,
			dec(16,2)	as Cr_axuiliar,
			dec(16,2)	as Tot_axuiliar;

define _error_desc			varchar(100);
define _res_descripcion		varchar(50);
define _nom_auxiliar		varchar(50);
define _nom_ramo			varchar(50);
define _res_comprobante		char(8);
define _res1_auxiliar		char(5);
define _res_origen			char(3);
define _db_auxiliar			dec(16,2);
define _cr_axuiliar			dec(16,2);
define _tot_axuiliar		dec(16,2);
define _tipo_registro		smallint;
define _error_isam			integer;
define _res_notrx			integer;
define _error				integer;
define _res_fechatrx		date;
define _fecha_desde			date;
define _fecha_hasta			date;
let _tot_axuiliar = 0;

--set debug file to 'sp_rea34.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return _error,'',_error_desc,'','',null,'',0.00,_error_isam,0.00;
end exception  

set isolation to dirty read;

let _fecha_desde = mdy(a_periodo[6,7],1,a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo);

foreach
	select res_descripcion,
		   res_comprobante,
		   res_fechatrx,
		   res_notrx,
		   res_origen,
		   res1_auxiliar,
		   res1_debito,
		   res1_credito
	  into _res_descripcion,
		   _res_comprobante,
		   _res_fechatrx,
		   _res_notrx,
		   _res_origen,
		   _res1_auxiliar,
		   _db_auxiliar,
		   _cr_axuiliar
	  from cglresumen, cglresumen1
	 where res_noregistro = res1_noregistro
	   and res_cuenta = a_cuenta
	   and res_fechatrx between _fecha_desde and _fecha_hasta

	foreach
		select nombre
		  into _nom_auxiliar
		  from emicoase
		 where aux_bouquet = _res1_auxiliar		 
	end foreach

	if _res_origen = 'REA' then
		foreach
			select m.tipo_registro,
				   r.nombre,
				   d.debito,
				   d.credito
			  into _tipo_registro,
				   _nom_ramo,
				   _db_auxiliar,
				   _cr_axuiliar
			  from sac999:reacomp m, sac999:reacompasiau d,emipomae e, prdramo r,sac999:reacompasie p
			 where m.no_registro = d.no_registro
			   and m.no_poliza   = e.no_poliza
			   and e.cod_ramo    = r.cod_ramo
			   and p.no_registro = d.no_registro
			   and p.cuenta      = d.cuenta
			   and p.sac_notrx   = _res_notrx
			   and d.periodo     = a_periodo
			   and d.cod_auxiliar = _res1_auxiliar
			   and d.cuenta = a_cuenta
			 order by 1
			 
			let _tot_axuiliar = _db_auxiliar - _cr_axuiliar;

			return	_tipo_registro,
					_res1_auxiliar,
					_nom_auxiliar,
					_nom_ramo,
					_res_comprobante,
					_res_fechatrx,
					_res_descripcion,
					_db_auxiliar,
					_cr_axuiliar,_tot_axuiliar with resume;
		end foreach
	else
	
		let _tot_axuiliar = _db_auxiliar - _cr_axuiliar ;
		return	0,
				_res1_auxiliar,
				_nom_auxiliar,
				'COMPROBANTE MANUAL',
				_res_comprobante,
				_res_fechatrx,
				_res_descripcion,
				_db_auxiliar,
				_cr_axuiliar,_tot_axuiliar with resume;
	end if
end foreach

end
end procedure;