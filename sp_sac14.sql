-- Procedure que Imprime los Comprobantes Pendientes de Postear

-- Creado    : 27/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac14;

create procedure "informix".sp_sac14()	
returning integer,
		  char(8),
		  date,
		  char(3),
		  char(50),
		  decimal(15,2),
		  decimal(15,2),
		  char(1),
		  char(3),
		  char(15),
		  datetime year to second,
		  char(1),
                  char(50);

define _trx1_notrx           integer;
define _trx1_comprobante     char(8);
define _trx1_fecha           date;
define _trx1_concepto        char(3);
define _trx1_descrip         char(50);
define _trx1_debito          decimal(15,2);
define _trx1_credito         decimal(15,2);
define _trx1_status          char(1);
define _trx1_origen          char(3);
define _trx1_usuario         char(15);
define _trx1_fechacap        datetime year to second;
define _trx1_diferencia		 char(1);
define _cia_nom			char(50);

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac";

foreach
 select trx1_notrx,
		trx1_comprobante,
		trx1_fecha,      
		trx1_concepto,   
		trx1_descrip,    
		trx1_debito,    
		trx1_credito,    
		trx1_status,     
		trx1_origen,     
		trx1_usuario,    
		trx1_fechacap   
   into _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap   
   from sac:cgltrx1
  order by trx1_fecha, trx1_notrx 

	if _trx1_debito = _trx1_credito then
		let _trx1_diferencia = "";
	else
		let _trx1_diferencia = "&";
	end if

	return _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap,
		_trx1_diferencia,
                _cia_nom
		with resume;   

end foreach

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac001";

foreach
 select trx1_notrx,
		trx1_comprobante,
		trx1_fecha,      
		trx1_concepto,   
		trx1_descrip,    
		trx1_debito,    
		trx1_credito,    
		trx1_status,     
		trx1_origen,     
		trx1_usuario,    
		trx1_fechacap   
   into _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap   
   from sac001:cgltrx1
  order by trx1_fecha, trx1_notrx 

	if _trx1_debito = _trx1_credito then
		let _trx1_diferencia = "";
	else
		let _trx1_diferencia = "&";
	end if

	return _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap,
		_trx1_diferencia,
                _cia_nom
		with resume;   

end foreach

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac002";

foreach
 select trx1_notrx,
		trx1_comprobante,
		trx1_fecha,      
		trx1_concepto,   
		trx1_descrip,    
		trx1_debito,    
		trx1_credito,    
		trx1_status,     
		trx1_origen,     
		trx1_usuario,    
		trx1_fechacap   
   into _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap   
   from sac002:cgltrx1
  order by trx1_fecha, trx1_notrx 

	if _trx1_debito = _trx1_credito then
		let _trx1_diferencia = "";
	else
		let _trx1_diferencia = "&";
	end if

	return _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap,
		_trx1_diferencia,
                _cia_nom
		with resume;   

end foreach

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac003";

foreach
 select trx1_notrx,
		trx1_comprobante,
		trx1_fecha,      
		trx1_concepto,   
		trx1_descrip,    
		trx1_debito,    
		trx1_credito,    
		trx1_status,     
		trx1_origen,     
		trx1_usuario,    
		trx1_fechacap   
   into _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap   
   from sac003:cgltrx1
  order by trx1_fecha, trx1_notrx 

	if _trx1_debito = _trx1_credito then
		let _trx1_diferencia = "";
	else
		let _trx1_diferencia = "&";
	end if

	return _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap,
		_trx1_diferencia,
                _cia_nom
		with resume;   

end foreach

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac004";

foreach
 select trx1_notrx,
		trx1_comprobante,
		trx1_fecha,      
		trx1_concepto,   
		trx1_descrip,    
		trx1_debito,    
		trx1_credito,    
		trx1_status,     
		trx1_origen,     
		trx1_usuario,    
		trx1_fechacap   
   into _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap   
   from sac004:cgltrx1
  order by trx1_fecha, trx1_notrx 

	if _trx1_debito = _trx1_credito then
		let _trx1_diferencia = "";
	else
		let _trx1_diferencia = "&";
	end if

	return _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap,
		_trx1_diferencia,
                _cia_nom
		with resume;   

end foreach

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac005";

foreach
 select trx1_notrx,
		trx1_comprobante,
		trx1_fecha,      
		trx1_concepto,   
		trx1_descrip,    
		trx1_debito,    
		trx1_credito,    
		trx1_status,     
		trx1_origen,     
		trx1_usuario,    
		trx1_fechacap   
   into _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap   
   from sac005:cgltrx1
  order by trx1_fecha, trx1_notrx 

	if _trx1_debito = _trx1_credito then
		let _trx1_diferencia = "";
	else
		let _trx1_diferencia = "&";
	end if

	return _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap,
		_trx1_diferencia,
                _cia_nom
		with resume;   

end foreach

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac006";

foreach
 select trx1_notrx,
		trx1_comprobante,
		trx1_fecha,      
		trx1_concepto,   
		trx1_descrip,    
		trx1_debito,    
		trx1_credito,    
		trx1_status,     
		trx1_origen,     
		trx1_usuario,    
		trx1_fechacap   
   into _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap   
   from sac006:cgltrx1
  order by trx1_fecha, trx1_notrx 

	if _trx1_debito = _trx1_credito then
		let _trx1_diferencia = "";
	else
		let _trx1_diferencia = "&";
	end if

	return _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap,
		_trx1_diferencia,
                _cia_nom
		with resume;   

end foreach

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac007";

foreach
 select trx1_notrx,
		trx1_comprobante,
		trx1_fecha,      
		trx1_concepto,   
		trx1_descrip,    
		trx1_debito,    
		trx1_credito,    
		trx1_status,     
		trx1_origen,     
		trx1_usuario,    
		trx1_fechacap   
   into _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap   
   from sac007:cgltrx1
  order by trx1_fecha, trx1_notrx 

	if _trx1_debito = _trx1_credito then
		let _trx1_diferencia = "";
	else
		let _trx1_diferencia = "&";
	end if

	return _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap,
		_trx1_diferencia,
                _cia_nom
		with resume;   

end foreach

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac008";

foreach
 select trx1_notrx,
		trx1_comprobante,
		trx1_fecha,      
		trx1_concepto,   
		trx1_descrip,    
		trx1_debito,    
		trx1_credito,    
		trx1_status,     
		trx1_origen,     
		trx1_usuario,    
		trx1_fechacap   
   into _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap   
   from sac008:cgltrx1
  order by trx1_fecha, trx1_notrx 

	if _trx1_debito = _trx1_credito then
		let _trx1_diferencia = "";
	else
		let _trx1_diferencia = "&";
	end if

	return _trx1_notrx,
		_trx1_comprobante,
		_trx1_fecha,      
		_trx1_concepto,   
		_trx1_descrip,    
		_trx1_debito,    
		_trx1_credito,    
		_trx1_status,     
		_trx1_origen,     
		_trx1_usuario,    
		_trx1_fechacap,
		_trx1_diferencia,
                _cia_nom
		with resume;   

end foreach

end procedure
