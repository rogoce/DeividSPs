-- Procedimiento que Verifica las sumas de chqcomis vs chqchmae
-- 
-- Creado    : 18/03/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che44;		

CREATE PROCEDURE "informix".sp_che44()
returning char(10),
          dec(16,2),
		  dec(16,2),
		  char(10),
		  char(1),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  char(1),
		  date,
		  char(1);

define _no_requis		char(10);
define _monto_cheque	dec(16,2);
define _monto_comis		dec(16,2);
define _monto_his		dec(16,2);
define _monto_tot		dec(16,2);
define _cod_agente		char(5);
define _tipo_agente		char(1);
define _nombre_agente	char(50);
define _cuenta 			char(25);
define _origen_cheque   char(1);
define _fecha_captura   date;
define _tipo_requis     char(1);

foreach
 select no_requis,
        monto,
		cod_agente,
		origen_cheque,
		fecha_captura,
		tipo_requis
   into _no_requis,
        _monto_cheque,
		_cod_agente,
		_origen_cheque,
		_fecha_captura,
		_tipo_requis
   from chqchmae
  where origen_cheque in (2,7)
    and fecha_impresion >= "03/07/2006"

	select sum(comision)
	  into _monto_comis		  
	  from chqcomis
	 where no_requis = _no_requis;

	if _monto_comis is null then
		let _monto_comis = 0.00;
	end if

	if _monto_cheque <> _monto_comis then
	 
		select sum(monto)
		  into _monto_his
		  from agtsalhi
		 where cod_agente = _cod_agente
		   and fecha_al = "30/06/2006";

		let _monto_tot = _monto_comis + _monto_his;

  		select nombre,
		       tipo_agente
		  into _nombre_agente,
		       _tipo_agente
		  from agtagent
		 where cod_agente = _cod_agente;

  {		LET _cuenta = sp_sis15('CPCXPAUX', '03', _cod_agente);

		update chqchcta
		   set debito    = debito  + _monto_his
		 where no_requis = _no_requis
		   and cuenta    = _cuenta;
   }
		return _no_requis,
		       _monto_cheque,
			   _monto_comis,
			   _cod_agente,
			   _tipo_agente,
			   _nombre_agente,
			   _monto_his,
			   _monto_tot,
			   _origen_cheque,
			   _fecha_captura,
			   _tipo_requis
			   with resume;

-- Estoy por Aqui

-- 1. Falta sacar el historico chqcomis de los cheques que no cuadran porque tuvieron historia
-- 2. Generar el chqcomis para los que no se le genero cheque y tienen acumulados
-- 3. Modificar sp_par203 para incluir el descuento de comision de los agentes especiales 
	
	end if

end foreach

end procedure