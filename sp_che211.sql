-- Procedure que retorna los cheques para propositos de auditoria

drop procedure sp_che211;

create procedure "informix".sp_che211()
returning date,
          integer,
		  char(50),
		  char(8),
		  char(3),
		  char(3),
		  char(10),
		  char(100),
		  dec(16,2),
		  char(255),
		  char(2),
		  date,
		  char(8);



define _fecha_impresion	date;
define _no_cheque		integer; 
define _origen_cheque	char(1); 
define _user_added		char(8); 
define _cod_banco		char(3); 
define _cod_chequera	char(3); 
define _no_requis		char(10); 
define _a_nombre_de		char(100); 
define _monto 			dec(16,2);
define _anulado 		smallint;
define _fecha_anulado 	date;
define _anulado_por		char(8);

define _renglon			smallint; 
define _desc_cheque		char(100);
define _descripcion		char(255);
define _desc_origen		char(50);
define _desc_anulado	char(2);

foreach
 select fecha_impresion, 
 	    no_cheque, 
 	    origen_cheque, 
 	    user_added, 
 	    cod_banco, 
 	    cod_chequera, 
 	    no_requis, 
 	    a_nombre_de, 
 	    monto, 
 	    anulado, 
 	    fecha_anulado, 
 	    anulado_por
   into _fecha_impresion, 
 	    _no_cheque, 
 	    _origen_cheque, 
 	    _user_added, 
 	    _cod_banco, 
 	    _cod_chequera, 
 	    _no_requis, 
 	    _a_nombre_de, 
 	    _monto, 
 	    _anulado, 
 	    _fecha_anulado, 
 	    _anulado_por
   from chqchmae
  where pagado          = 1
    and fecha_impresion >= "01/01/2012"
    and fecha_impresion <= "11/07/2012"
    and tipo_requis   = "C"
    and (firma1 is null or firma2 is null)
--    and no_cheque = 221119
  order by fecha_impresion, no_cheque

	let _desc_anulado = "";

	if _anulado = 1 then
		let _desc_anulado = "Si";
	end if

	if _origen_cheque = "1" then
		let _desc_origen = "1. Contabilidad";
	elif _origen_cheque = "2" then
		let _desc_origen = "2. Corredor";
	elif _origen_cheque = "3" then
		let _desc_origen = "3. Reclamos";
	elif _origen_cheque = "4" then
		let _desc_origen = "4. Reaseguro";
	elif _origen_cheque = "5" then
		let _desc_origen = "5. Coaseguro";
	elif _origen_cheque = "6" then
		let _desc_origen = "6. Cobros";
	elif _origen_cheque = "7" then
		let _desc_origen = "7. Honorarios";
	elif _origen_cheque = "8" then
		let _desc_origen = "8. Bonificacion Cobranza Agentes";
	elif _origen_cheque = "9" then
		let _desc_origen = "9. Incentivo de Fidelidad Agentes";
	elif _origen_cheque = "A" then
		let _desc_origen = "A. Honorarios por Servicios Profesionales";
	elif _origen_cheque = "B" then
		let _desc_origen = "B. Servicios Basicos";
	elif _origen_cheque = "C" then
		let _desc_origen = "C. Alquileres por Arrendamientos Comerciales";
	elif _origen_cheque = "D" then
		let _desc_origen = "D. Bonificacion por Rentabilidad Agentes";
	elif _origen_cheque = "E" then
		let _desc_origen = "E. Bonificacion Reclutamiento";
	elif _origen_cheque = "P" then
		let _desc_origen = "P. Planilla";
	elif _origen_cheque = "G" then
		let _desc_origen = "G. Gastos Administrativos";
	elif _origen_cheque = "S" then
		let _desc_origen = "S. Devolucion Prima Suspenso";
	end if

	let _descripcion = "";

	foreach
	 select renglon, 
 	    	desc_cheque
 	   into _renglon, 
 	    	_desc_cheque 	 
	   from chqchdes
	  where no_requis = _no_requis
	  order by renglon

		let _descripcion = trim(_descripcion) || _desc_cheque;

	end foreach

	return _fecha_impresion, 
 	       _no_cheque, 
 	       _desc_origen, 
 	       _user_added, 
 	       _cod_banco, 
 	       _cod_chequera, 
 	       _no_requis, 
 	       _a_nombre_de, 
 	       _monto, 
		   _descripcion,
 	       _desc_anulado, 
 	       _fecha_anulado, 
 	       _anulado_por
		   with resume;

end foreach

end procedure
