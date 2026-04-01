-- Procedimiento que verifica el cuadre contable con las cuentas tecnicas de cobros y auxiliar
-- Creado    : 20/11/2019 - Autor: Henry Giron
--execute procedure sp_sac250('001','001','2019-09','2019-09','001,003,006,008,010,011,012,013,014,021,022;','231010201')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac250;
create procedure informix.sp_sac250(
a_compania  char(3), 
a_agencia   char(3), 
a_periodo1  char(7), 
a_periodo2  char(7),
a_cod_ramo	varchar(100),
a_cuenta    varchar(100))
returning	varchar(50)		as compania,
			varchar(50)		as nom_cuenta,
			char(18)		as cuenta,			
			char(3)			as origen,
			dec(16,2)		as db,
			dec(16,2)		as cr,
			dec(16,2)		as monto_tecnico,
			integer			as sac_notrx,
			char(10)		as no_remesa,
			integer			as renglon,
			char(15)		as comprobante,
			char(10)		as no_tranrec,
			char(10)		as factura,
			varchar(255)	as descripcion,			
			char(50)        as name_coasegur,
			char(20)        as poliza;

define _no_documento		char(20);
define _descripcion			varchar(255);
define _error_desc			varchar(255);
define v_compania_nombre	varchar(50);
define _nom_cuenta			varchar(50);
define _cuenta				char(18);
define _res_comprobante		char(15);
define _no_factura			char(10);
define _no_tranrec			char(10);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _res_origen			char(3);
define _tipo				char(1);
define _prima_cobrada		dec(16,2);
define _mto_recasien		dec(16,2);
define _res_db				dec(16,2);
define _res_cr				dec(16,2);
define _monto				dec(16,2);
define _dif					dec(16,2);
define _db					dec(16,2);
define _cr					dec(16,2);
define _cnt_cglresumen		smallint;
define _cnt1		smallint;
define _error_isam			integer;
define _res_notrx			integer;
define _sac_notrx			integer;
define _renglon				integer;
define _error				integer;
define _fecha1				date;
define _fecha2				date;
define _cod_ramo     	    char(3);
define _cod_subramo     	char(3);
define _cod_coasegur		char(3);
define _cod_origen_aseg		char(3);
define _cod_auxiliar		char(5);	
define _name_coasegur	    char(50);
define a_codramo            char(255);
define a_serie              char(255);

set isolation to dirty read;

--set debug file to "sp_sac250.trc";
--trace on;


drop table if exists tmp_contable1;
drop table if exists tmp_codigos;

begin 
on exception set _error, _error_isam, _error_desc
	drop table if exists tmp_contable1;
	drop table if exists tmp_codigos;
	
	{drop table if exists temp_det;
	drop table if exists temp_produccion;}	
	
	return trim(_error_desc),'',a_cuenta,'',0.00,0.00,0.00,_error,'',0,'','','','','','';
end exception


let v_compania_nombre = '';
let _res_comprobante = '';
let _res_origen = '';
let _nom_cuenta = '';
let _no_tranrec = '';
let _no_remesa = '';
let _cuenta = '';
let _db = 0.00;
let _cr = 0.00;
let _res_notrx = 0;
let _renglon = 0;

let v_compania_nombre = sp_sis01(a_compania);
let a_codramo = "001,003,006,008,010,011,012,013,014,021,022;";
let a_serie = "2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008;";

--Procedure de Generacion de Primas Suscrita para el periodo dado.
call sp_pr123a('001','001',a_periodo1,a_periodo2,"*","*","*","*",a_codramo,"*","*",a_serie,0)
returning _error, _error_desc;
if _error <> 0 then
	return 'Generacion Prima Suscrita/Siniestro, Error: ' || trim(_error_desc),'',a_cuenta,'',0.00,0.00,0.00,_error,'',0,'','','','','','';
end if
--Procedure de Generacion de Primas Cobrada para el periodo dado.
call sp_pr860f('001','001',a_periodo1,a_periodo2,"*","*","*","*",a_codramo,"*",a_serie,"01","*")
returning _error, _error_desc;
if _error <> 0 then
	return 'Generacion Prima Suscrita/Siniestro, Error: ' || trim(_error_desc),'',a_cuenta,'',0.00,0.00,0.00,_error,'',0,'','','','','','';
end if

call sp_sac251(a_compania,a_agencia,a_periodo1,a_periodo2,a_cuenta) returning _error, _error_desc;
if _error <> 0 then
	return 'Cuadre Contable, Error: ' || trim(_error_desc),'',a_cuenta,'',0.00,0.00,0.00,_error,'',0,'','','','','','';
end if

--Filtro por Cuentas
if a_cuenta <> "*" then
	let _error_desc = trim(_error_desc) ||"Cuenta: "||trim(a_cuenta);
	let _tipo = sp_sis04(a_cuenta); -- separa los valores del string
end if

foreach
	select cod_ramo,cod_subramo,no_remesa,renglon,cod_coasegur,sum(por_pagar)
	  into _cod_ramo,_cod_subramo,_no_remesa,_renglon,_cod_coasegur,_prima_cobrada
 	  from temp_produccion
	 --where no_remesa = '1507628' and no_poliza = '1273235'	-- and cuenta = '231010201'
	 group by cod_ramo,cod_subramo,no_remesa,renglon,cod_coasegur
	
	if _prima_cobrada is null then
		let _prima_cobrada = 0.00;
	end if
	
	if _prima_cobrada = 0.00 then
		continue foreach;
	end if		   

	select cod_origen,
		   aux_bouquet
	  into _cod_origen_aseg,
		   _cod_auxiliar
	  from emicoase
	 where cod_coasegur = _cod_coasegur;
	 
	let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   	 			
	
	select count(*)
	  into _cnt1
	   from sac999:reacompasie b, sac999:reacomp c, sac999:reacompasiau a, cglterceros t
	  where b.no_registro = c.no_registro
	    and a.no_registro  = b.no_registro
		and a.cuenta       = b.cuenta
		and a.cod_auxiliar = t.ter_codigo
		and a.cuenta       = b.cuenta
		and c.tipo_registro = "2"
		and c.no_remesa = _no_remesa
        and c.renglon = _renglon
	    and a.cod_auxiliar = _cod_auxiliar
        and a.cuenta = _cuenta ;     

	if _cnt1 is null then
		let _cnt1 = 0;
	end if

	if _cnt1 = 0 then							
						
		insert into tmp_contable1(
				cuenta,
				no_remesa,
				renglon,
				db,
				cr,
				sac_notrx,
				origen,
				monto_tecnico,
				descripcion)
		values(	_cuenta,
				_no_remesa,
				_renglon,
				0.00,
				0.00,
				'',
				'COB',
				_prima_cobrada,
				'NO EXISTE ASIENTO DE AUILIAR EN LA REMESA',
				_cod_auxiliar,_prima_cobrada);
	
	end if
	
end foreach
	    
		
foreach
	select cuenta,
		   no_remesa,
		   renglon,
		   db,
		   cr, 
		   sac_notrx,
		   comprobante,
		   origen,
		   monto_tecnico,
		   no_poliza,
		   no_endoso,
		   descripcion,
		   cod_coasegur,
		   name_coasegur,
		   dif
	  into _cuenta,
	       _no_remesa,
		   _renglon,
		   _db,
		   _cr,
		   _res_notrx,
		   _res_comprobante,
		   _res_origen,
		   _prima_cobrada,
		   _no_poliza,
		   _no_endoso,
		   _descripcion,
		   _cod_coasegur,
		   _name_coasegur,
		   _dif
	  from tmp_contable1
	 order by cuenta,origen,name_coasegur,sac_notrx

	select cta_nombre
	  into _nom_cuenta
	  from cglcuentas
	 where cta_cuenta = _cuenta;
	 
	select trim(no_documento)
	  into _no_documento
	  from temp_det
	 where no_remesa = _no_remesa
	   and renglon = _renglon;	 	 

	return	v_compania_nombre,
			_nom_cuenta,
			_cuenta,
			_res_origen,
			_db,
			_cr,
			_prima_cobrada,
			_res_notrx,
			_no_remesa,
			_renglon,
			_res_comprobante,
			_no_tranrec,
			_no_remesa,
			_descripcion,
			_name_coasegur,
			_no_documento
			with resume;
end foreach
end



end procedure;