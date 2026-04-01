-- Procedimiento que crea los registros para programa de 3 opciones en renovacion.

-- CREADO: 14/11/2001 POR: Amado
-- CREADO: 26/11/2004 POR: Armando

--drop procedure sp_pro82d;

create procedure "informix".sp_pro82d(
v_poliza 			char(10),
a_suma				dec(16,2),
a_no_unidad 		char(5),
a_porc_depre_pol 	dec(5,2)
)
returning dec(16,2), 	--suma depreciada
		  integer;		--saber si se han usado los descuentos en las opciones

DEFINE r_anos          smallint;
DEFINE _porc_depre     DEC(5,2);
DEFINE _porc_depre_uni DEC(5,2);
DEFINE _porc_depre_pol DEC(5,2);
DEFINE _valor_asignar  CHAR(1); 
DEFINE _cant  		   INTEGER;
DEFINE _cant1  		   INTEGER;
DEFINE _cant2  		   INTEGER;
DEFINE _suma_asegurada DEC(16,2);
DEFINE _suma_decimal   DEC(16,2);
DEFINE _suma_difer	   DEC(16,2);
DEFINE _suma_ant	   DEC(16,2);
DEFINE _prima_anual    DEC(16,2);
DEFINE _prima          DEC(16,2);
DEFINE _descuento      DEC(16,2);
DEFINE _recargo        DEC(16,2);
DEFINE _prima_neta	   DEC(16,2);
DEFINE _porc_descuento  DEC(5,2);
define _porc_descuento0	DEC(5,2);
DEFINE _porc_descuento1 DEC(5,2);
DEFINE _porc_descuento2 DEC(5,2);
define _suma_a          integer;

define _cod_ramo        char(3);
define _cod_tipoveh     char(3);
define _no_motor 		char(30);
define _uso_auto 		char(1);
define _nuevo           smallint;


SET DEBUG FILE TO "sp_pro82d.trc"; 
trace on;

let _cant  = 0;
let _cant1 = 0;
let _cant2 = 0;
let _suma_a = 0;

BEGIN
	SELECT sum(porc_descuento)
	  INTO _porc_descuento
	  FROM emiunide
	 WHERE no_poliza = v_poliza
	   and no_unidad = a_no_unidad;

	SELECT sum(porc_descuento)
	  INTO _porc_descuento0
	  FROM emirede0
	 WHERE no_poliza = v_poliza
	   and no_unidad = a_no_unidad;

	SELECT sum(porc_descuento)
	  INTO _porc_descuento1
	  FROM emirede1
	 WHERE no_poliza = v_poliza
	   and no_unidad = a_no_unidad;

	SELECT sum(porc_descuento)
	  INTO _porc_descuento2
	  FROM emirede2
	 WHERE no_poliza = v_poliza
	   and no_unidad = a_no_unidad;

	if (_porc_descuento = _porc_descuento0) and (_porc_descuento = _porc_descuento1) and (_porc_descuento = _porc_descuento2) then
		let _cant = 1;	--no se han usado los descuentos(opciones)
	elif (_porc_descuento = _porc_descuento1) and (_porc_descuento = _porc_descuento0) then
		let _cant = 3;  --se ha usado opcion2
	elif (_porc_descuento = _porc_descuento2) and (_porc_descuento = _porc_descuento0) then
		let _cant = 2;  --se ha usado opcion1
	elif (_porc_descuento = _porc_descuento1) and (_porc_descuento = _porc_descuento2) then
		let _cant = 5;  --se ha usado renovacion
	else
		let _cant = 4;	--se ha usado renovacion, opcion1 y opcion2
	end if

	-- Calculo de la Depreciacion

	let _porc_depre_pol = a_porc_depre_pol;
	
	
	--- adicion SD#5155 JEPEREZ inicio
	 	SELECT cod_ramo
		  INTO _cod_ramo
		  from emipomae
		 where no_poliza = v_poliza;

		if _cod_ramo in ('002','020','023') then			

			let _porc_depre	= a_porc_depre_pol;			

			select no_motor,
				   uso_auto,
				   cod_tipoveh
			  into _no_motor,
				   _uso_auto,
				   _cod_tipoveh
			  from emiauto
			 where no_poliza = v_poliza
			   and no_unidad = a_no_unidad;

			select nuevo
			  into _nuevo
			  from emivehic
			 where no_motor = _no_motor;
			 
			 {
             TIPO VEHICULO	003 TAXIS
             USO	COMERCIAL – C
             CONDICION	NUEVO	USADO
             % DEPRECIACION	20	15			 
			 }
			 
			 if _cod_tipoveh = '003' then
				if _uso_auto = 'C' then
					if _nuevo = 1 then
						let _porc_depre	= 20;	
					else
						let _porc_depre	= 15;							
					end if	
                    let _porc_depre_pol = _porc_depre;					
					let a_porc_depre_pol = _porc_depre;	
				end if
			 end if 
			let _porc_depre_pol = a_porc_depre_pol; 
		end if			 
	--- adicion SD#5155 JEPEREZ fin
	
	let _suma_decimal   = a_suma;
	let _suma_ant       = _suma_decimal;

	LET _porc_depre = _porc_depre_pol;

	IF a_porc_depre_pol <> 0.00 THEN
		LET _suma_asegurada = _suma_decimal * (1 - _porc_depre/100);
		LET _suma_decimal   = _suma_decimal * (1 - _porc_depre/100);
	ELSE
		LET _suma_asegurada = _suma_decimal;
	END IF
	--select cod_ramo into _cod_ramo from emipomae where no_poliza = v_poliza;


	LET _suma_difer = _suma_decimal - _suma_asegurada;

	IF _suma_difer >= 0.5 THEN
		LET _suma_asegurada = _suma_asegurada + 1;
	END IF

	if _cod_ramo = "002" or _cod_ramo = "020" then
		let _suma_a = _suma_asegurada;
		let _suma_asegurada = _suma_a;
	end if
	return _suma_asegurada,
		   _cant;

END

end procedure;
