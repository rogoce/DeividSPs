-- Procedimiento que Carga el Incurridos netos de los Reclamos 
-- en un Periodo Dado
--
-- Creado    : 10/06/2014 - Autor: ANGEL TELLO
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec01b4;
create procedure informix.sp_rec01b4(
a_compania  char(3), 
a_agencia   char(3), 
a_periodo1  char(7), 
a_periodo2  char(7), 
a_cuenta    char(18))
returning	varchar(50)	as compania,
			varchar(50)	as nom_cuenta,
			char(18)	as cuenta,			
			char(3)		as origen,
			dec(16,2)	as db,
			dec(16,2)	as cr,
			integer     as sac_notrx,
			char(10)    as no_remesa,
			integer     as renglon,
			char(15)    as comprobante,
			char(10)    as no_tranrec;

define _nom_cuenta			varchar(50);
define v_compania_nombre	varchar(50);
define _cuenta				char(18);
define _res_notrx           integer;
define _res_origen          char(3);
define _monto				dec(16,2);
define _fecha1				date;
define _fecha2				date;
define _mto_cobasien		dec(16,2);
define _db					dec(16,2);
define _cr					dec(16,2);
define _no_remesa           char(10);
define _renglon				integer;
define _mto_recasien		dec(16,2);
define _dif					dec(16,2);
define _no_tranrec			char(10);
define _res_comprobante		char(15);
define _res_db				dec(16,2);
define _res_cr				dec(16,2);


let v_compania_nombre = sp_sis01(a_compania);
drop table if exists tmp_salida;

let _monto = 0;
let _mto_cobasien = 0;
let _mto_recasien = 0;
let _db           = 0;
let _cr           = 0;
let _res_db	      = 0;
let _res_cr       = 0;
let _dif          = 0;

create temp table tmp_salida(
cuenta		char(18),
no_remesa	char(10),
renglon     integer,
db          dec(16,2),
cr          dec(16,2),
sac_notrx   integer,
comprobante char(15),
no_tranrec  char(10),
origen      char(3)
) with no log;

let _fecha1 = sp_sis36bk(a_periodo1); --retorna 01/11/2015 si el periodo es 2015-11
let _fecha2 = sp_sis36(a_periodo1);   --retorna 30/11/2015 si el periodo es 2015-11

foreach
	select res_notrx,
	       res_origen,
		   sum(res_debito-res_credito)
	  into _res_notrx,
	       _res_origen,
		   _monto
	from cglresumen
	where res_cuenta = a_cuenta
	  and res_fechatrx >= _fecha1
	  and res_fechatrx <= _fecha2
	group by 1,2
	order by 2,1 

	let _dif = 0;
	if _res_origen = 'COB' then
		select sum(debito-credito)
		  into _mto_cobasien
		  from cobasien
		 where sac_notrx = _res_notrx
           and cuenta    = a_cuenta
		   and periodo   = a_periodo1;
		   
		let _dif = ABS(_monto - _mto_cobasien);
		if _dif = 0 then
			continue foreach;
		else
		 foreach
			select no_remesa,
			       renglon,
				   debito,
				   credito
			  into _no_remesa,
			       _renglon,
				   _db,
				   _cr
			  from cobasien
			 where sac_notrx = _res_notrx
			   and cuenta    = a_cuenta
			   and periodo   = a_periodo1
		   
			insert into tmp_salida(
					cuenta,
					no_remesa,
					renglon,
					db,
					cr,
					sac_notrx,
					origen
					)
			values(	a_cuenta,
					_no_remesa,
					_renglon,
					_db,
					_cr,
					_res_notrx,
					_res_origen
					);
		 end foreach			
		end if
	elif _res_origen = 'REC' then
		select sum(debito+credito)
		  into _mto_recasien
		  from recasien
		 where sac_notrx = _res_notrx
           and cuenta    = a_cuenta
		   and periodo   = a_periodo1;
		   
		let _dif = ABS(_monto - _mto_recasien);
		if  _dif = 0 then
			continue foreach;
		else
		    foreach
				select no_tranrec,
					   debito,
					   credito
				  into _no_tranrec,
					   _db,
					   _cr
				  from recasien
				 where sac_notrx = _res_notrx
				   and cuenta    = a_cuenta
				   and periodo   = a_periodo1
			   
				insert into tmp_salida(
						cuenta,
						no_tranrec,
						db,
						cr,
						sac_notrx,
						origen
						)
				values(	a_cuenta,
						_no_tranrec,
						_db,
						_cr,
						_res_notrx,
						_res_origen);
			end foreach		
		end if			
	elif _res_origen = 'CGL' then
		foreach
			select res_comprobante,
			       res_debito,
				   res_credito
			  into _res_comprobante,
                   _res_db,
                   _res_cr
              from cglresumen
             where res_cuenta = a_cuenta
			   and res_fechatrx >= _fecha1
			   and res_fechatrx <= _fecha2
			   and res_origen = 'CGL'
			   and res_notrx  = _res_notrx
			  
   			insert into tmp_salida(
					cuenta,
					origen,
					db,
					cr,
					sac_notrx,
					comprobante
					)
			values(	a_cuenta,
					_res_origen,
					_res_db,
					_res_cr,
					_res_notrx,
					_res_comprobante);
		end foreach			
	end if
end foreach

select cta_nombre
  into _nom_cuenta
  from cglcuentas
 where cta_cuenta = a_cuenta; 
  
foreach
	select cuenta,
		   no_remesa,
		   renglon,
		   db,
		   cr, 
		   sac_notrx,
		   comprobante,
		   no_tranrec,
		   origen
	  into _cuenta,
	       _no_remesa,
		   _renglon,
		   _db,
		   _cr,
		   _res_notrx,
		   _res_comprobante,
		   _no_tranrec,
		   _res_origen
	  from tmp_salida
	 order by origen,sac_notrx
	 
	return	v_compania_nombre,
			_nom_cuenta,
			_cuenta,
			_res_origen,
			_db,
			_cr,
			_res_notrx,
			_no_remesa,
			_renglon,
			_res_comprobante,
			_no_tranrec
			with resume;
end foreach

drop table if exists tmp_salida;
end procedure;