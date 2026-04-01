
drop procedure sp_bo045c;

create procedure sp_bo045c(a_agente CHAR(10), a_fecha_desde DATE, a_fecha_hasta DATE, a_requis CHAR(10))
returning char(10),
          date,
		  dec(16,2),
		  dec(16,2),
		  char(10),
		  varchar(100),
		  date,
		  date,
		  dec(16,2),
		  char(1),
		  CHAR(100);

define _no_requis	char(10);
define _monto_che	dec(16,2);
define _monto_com	dec(16,2);
define _fecha		date;
define _cod_agente	char(10);
define _desc_cheque varchar(100);
define _fecha_desde date;
define _fecha_hasta date;
define _dia         char(2);
define _mes         char(2);
define _ano2        char(4);
define v_comision   dec(16,2);
DEFINE v_no_poliza  CHAR(10); 
DEFINE v_no_recibo  CHAR(10); 
DEFINE v_fecha      DATE;   
define _dia_s       SMALLINT;
DEFINE _tipo_requis CHAR(1);  
DEFINE _a_nombre_de CHAR(100);

{CREATE TEMP TABLE tmp_agente(
	cod_agente		CHAR(15),
	no_poliza		CHAR(10),
	no_recibo		CHAR(10),
	fecha			DATE,
	monto           DEC(16,2),
	prima           DEC(16,2),
	porc_partic		DEC(5,2),
	porc_comis		DEC(5,2),
	comision		DEC(16,2),
	nombre			CHAR(50),
	no_documento    CHAR(20),
	monto_vida      DEC(16,2),
	monto_danos     DEC(16,2),
	monto_fianza    DEC(16,2),
	no_licencia     CHAR(10),
	seleccionado    SMALLINT DEFAULT 1,
	PRIMARY KEY		(cod_agente, no_poliza, no_recibo, fecha)
	) WITH NO LOG;
 }

set isolation to dirty read;

--DROP TABLE tmp_agente;

foreach
 select no_requis,
        monto,
		fecha_captura,
		cod_agente,
		tipo_requis,
		a_nombre_de
   into	_no_requis,
        _monto_che,
		_fecha,
		_cod_agente,
		_tipo_requis,
		_a_nombre_de
   from chqchmae
  where fecha_impresion >= "17/01/2008"
    and fecha_impresion <= "17/01/2008"
    and origen_cheque   = 2
    and pagado          = 1
    and anulado         = 0
	and cod_agente      matches a_agente
	and no_requis       matches a_requis

	 select sum(comision)
	   into _monto_com
	   from chqcomis
	  where no_requis = _no_requis;
-- }
{	 
     select count(comision)
	   into _monto_com
	   from chqcomis
	  where no_requis = _no_requis;
-- }
	if _monto_com is null then
		let _monto_com = 0;
	end if

	if _monto_che <> _monto_com then

	   --	if _monto_com = 0 then

	        select desc_cheque
			  into _desc_cheque
			  from chqchdes
			 where no_requis = _no_requis
			   and renglon = 1;

		    LET _dia = substring(_desc_cheque from 22 for 23);
		    LET _mes = substring(_desc_cheque from 25 for 26);
		    LET _ano2 = substring(_desc_cheque from 28 for 31);

		    LET _fecha_desde = date(_dia||"/"||_mes||"/"||_ano2);
{			IF 	_dia = "16" THEN
			 	LET _fecha_desde = _fecha_desde + 8 UNITS MONTH;
		   	  	LET _fecha_desde = _fecha_desde - 15 UNITS DAY;
			ELSE
			 	LET _fecha_desde = _fecha_desde + 7 UNITS MONTH;
			  	LET _fecha_desde = _fecha_desde + 15 UNITS DAY;
			END IF
 }
		    LET _dia = substring(_desc_cheque from 36 for 37);
		    LET _mes = substring(_desc_cheque from 39 for 40);
		    LET _ano2 = substring(_desc_cheque from 42 for 45);
		    LET _fecha_hasta = date(_dia||"/"||_mes||"/"||_ano2);

          --  rstoi(_dia, &_dia_s); 
            
 {			IF 	_dia > "15" THEN
 --			 	LET _fecha_desde = date("16"||"/"||_mes||"/"||_ano2);

				LET _fecha_desde = date("01"||"/"||_mes||"/"||_ano2);
			 	LET _fecha_desde = _fecha_desde - 8 UNITS MONTH;
			ELSE
--			 	LET _fecha_desde = date("01"||"/"||_mes||"/"||_ano2);

				LET _fecha_desde = date("15"||"/"||_mes||"/"||_ano2);
			 	LET _fecha_desde = _fecha_desde - 9 UNITS MONTH;
			END IF
}

			LET v_comision = 0;

 			CALL sp_bo045b(
			"001", 
			"001",
			a_fecha_desde,
			a_fecha_hasta,
			_cod_agente
			);

-- SE HABILITA EN CASO QUE FALTE DATOS EN CHQCHCOMIS


{			SELECT sum(comision)
			  INTO v_comision 
			  FROM tmp_agente	
			 WHERE cod_agente = _cod_agente;

            IF v_comision = _monto_che THEN
 }
  -- 		  	UPDATE chqcomis
--				   SET no_requis = null
--				 WHERE no_requis  = _no_requis;

				execute procedure sp_che35b(a_fecha_desde, a_fecha_hasta, _cod_agente, _no_requis);
--}	 
-- SE HABILITA EN CASO QUE AL GENERAR CUADRE CON LO QUE DICE EN EL CHEQUE

   {             FOREACH	with hold
					 SELECT	no_poliza,
							no_recibo,
							fecha					   
					   INTO	v_no_poliza,
							v_no_recibo,
							v_fecha
					   FROM	tmp_agente	
					  WHERE cod_agente = _cod_agente

					 UPDATE chqcomis
					    SET no_requis  = _no_requis
					  WHERE cod_agente = _cod_agente
					    AND no_poliza  = v_no_poliza
						AND no_recibo  = v_no_recibo
						AND fecha      = v_fecha;

		   		END FOREACH
	}	   
 --			END IF	 
  
			return _no_requis,
			       _fecha,
				   _monto_che,
				   _monto_com,
				   _cod_agente,
				   _desc_cheque,
				   _fecha_desde,
				   _fecha_hasta,
				   v_comision,
				   _tipo_requis,
				   _a_nombre_de
				   with resume;

  		  	DROP TABLE tmp_agente;

  --		end if

	end if
	
end foreach



end procedure 