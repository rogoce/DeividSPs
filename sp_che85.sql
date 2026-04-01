--***************************************************************--
-- Procedimiento que Carga tabla CHQFIDEL Incentivos de Fidelidad--
--***************************************************************--

-- Creado    : 02/05/2008 - Autor: Armando Moreno M.
-- Modificado: 02/05/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che85;

CREATE PROCEDURE sp_che85
(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_periodo           CHAR(7),
a_usuario           CHAR(8)
)
RETURNING SMALLINT,
          char(50),
		  char(3);

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _no_documento    CHAR(20); 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _serie    		integer;
define _estatus_poliza  smallint;
DEFINE _per_cero        CHAR(7);
define _prima_neta		DEC(16,2);
define _saldo			DEC(16,2);
define _nueva_renov     char(1);
define _ano_act         integer;
define _per_ant   		char(7);
define _ano_ant			integer;
define v_nombre_clte    char(100);
DEFINE _no_licencia     CHAR(10);
define _cod_subramo     char(3);
define _cod_contr       char(10);
define _cod_origen      char(3);
define _cnt_ant			integer;
define _cnt_act			integer;
define _cnt             smallint;
DEFINE _valor           DEC(5,2);
DEFINE _porcentaje      DEC(5,2);
DEFINE _valor_prima     DEC(16,2);
DEFINE _nombre          CHAR(50);
define _suc_origen      char(3);
define _beneficios      smallint;
define _error           integer;
define _error_isam		integer;
define _error_desc		char(50);

--SET DEBUG FILE TO "sp_che85.trc";
--TRACE ON;
let _prima_neta = 0;
let _ano_act    = a_periodo[1,4];
let _ano_ant    = _ano_act - 1;
let _per_cero   = "";
let _saldo      = 0;
let _per_ant    = _ano_ant || '-' || a_periodo[6,7];

SET ISOLATION TO DIRTY READ;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

FOREACH

    select no_documento
	  into _no_documento
	  from incent07
	 where seleccionado = 0
	 group by no_documento
	 order by no_documento

   	let _no_poliza = sp_sis21(_no_documento);

  	select sucursal_origen,
		   estatus_poliza
	  into _suc_origen,
   		   _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	select beneficios
	  into _beneficios
	  from insagen
	 where codigo_agencia  = _suc_origen
	   and codigo_compania = a_compania;

	if _beneficios = 0 then

		INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (a_periodo,_no_documento,'La Suc. no paga beneficios: ' || _suc_origen,1);
		continue foreach;

	end if

	if _estatus_poliza in (2,3) then  --Excluir polizas canceladas y vencidas
		INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (a_periodo,_no_documento,'La Poliza esta Vencida o Cancelada.',1);
		continue foreach;
	end if

   	let _no_poliza = sp_sis382(_no_documento,a_periodo); --buscar el no_poliza del año que se esta pagando

	if _no_poliza = "" then
		INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (a_periodo,_no_documento,'Vigencia no corresponde al año que estan pagando.',1);
		continue foreach;
	end if

  	select nueva_renov,
	       serie,
		   prima_neta,
		   cod_ramo,
		   sucursal_origen,
		   estatus_poliza
	  into _nueva_renov,
	       _serie,
		   _prima_neta,
		   _cod_ramo,
		   _suc_origen,
   		   _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

    if _nueva_renov = 'R' and _serie = _ano_act then  --Esta renovada
		
	   	let _per_cero = sp_sis381(a_compania,_no_documento,a_periodo,1,_no_poliza);

	   	if _per_cero <> a_periodo then --no fue pagada el mes que estan incentivando.

			INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (a_periodo,_no_documento,'No fue pagada en el mes del Incentivo: ' || a_periodo,1);
			continue foreach;

		else

			update incent07
			   set seleccionado = 1
			 where no_documento = _no_documento
			   and periodo      = _per_ant;

			foreach

			    select cod_agente
				  into _cod_agente
				  from incent07
				 where no_documento = _no_documento
				   and periodo      = _per_ant

				--FF SEGUROS no entra en plan de negocios. 17/09/09
				if _cod_agente in("01068","01653","01654","01655","01656","01657","01658","01659","01660","01661","01662","01663","01664") then
					continue foreach;
				end if

				INSERT INTO incent08(periodo,no_poliza,cod_ramo,cod_agente,prima_neta,no_documento)
				VALUES(a_periodo,_no_poliza,_cod_ramo,_cod_agente,_prima_neta,_no_documento);

			end foreach

	   	end if

	else

		INSERT INTO bonibita(periodo,poliza,descripcion,tipo)	VALUES (a_periodo,_no_documento,'No Renovada.',1);
		continue foreach;

	end if

END FOREACH

let _cnt     = 0;
let _cnt_act = 0;
let _cnt_ant = 0;

foreach

	select cod_agente,
	       cod_ramo,
	       count(*)
	  into _cod_agente,
	       _cod_ramo,
		   _cnt_act
      from incent08
     where periodo = a_periodo
	 group by 1,2
	 order by 1,2

	--FF SEGUROS no entra en plan de negocios. 17/09/09
	if _cod_agente in("01068","01653","01654","01655","01656","01657","01658","01659","01660","01661","01662","01663","01664") then
		continue foreach;
	end if

		foreach

			select cod_ramo,
			       count(*)
			  into _cod_ramo,
				   _cnt_ant
		      from incent07
		     where periodo    = _per_ant
			   and cod_agente = _cod_agente
			   and cod_ramo   = _cod_ramo
			 group by 1
			 order by 1

			let _valor = 0;
			let _valor = (_cnt_act / _cnt_ant) * 100;

			SELECT nombre,
			       no_licencia
			  INTO _nombre,
			       _no_licencia
			  FROM agtagent
			 WHERE cod_agente = _cod_agente;

			    --persistencia para cada poliza para el periodo, corredor y ramo

				foreach

					select no_documento,
					       prima_neta,
						   no_poliza
					  into _no_documento,
					       _prima_neta,
						   _no_poliza
					  from incent08
				     where periodo    = a_periodo
					   and cod_agente = _cod_agente
					   and cod_ramo   = _cod_ramo

					let _valor_prima = 0;
					let _porcentaje  = 0;

					if _cod_ramo <> "018" then

						if _valor > 96 then
							let _valor_prima = _prima_neta * (2.5 / 100);
							let _porcentaje = 2.5;
						end if
						if _valor > 86 and _valor <= 95 then
							let _valor_prima = _prima_neta * (2.0 / 100);
							let _porcentaje = 2.0;
						end if
						if _valor > 76 and _valor <= 85 then
							let _valor_prima = _prima_neta * (1.5 / 100);
							let _porcentaje = 1.5;
						end if
						if _valor > 70 and _valor <= 75 then
							let _valor_prima = _prima_neta * (1.0 / 100);
							let _porcentaje = 1.0;
						end if

					else

						if _valor > 96 then
							let _valor_prima = _prima_neta * (2.5 / 100);
							let _porcentaje = 2.5;
						end if
						if _valor > 91 and _valor <= 95 then
							let _valor_prima = _prima_neta * (2.0 / 100);
							let _porcentaje = 2.0;
						end if
						if _valor > 86 and _valor <= 90 then
							let _valor_prima = _prima_neta * (1.5 / 100);
							let _porcentaje = 1.5;
						end if
						if _valor > 80 and _valor <= 85 then
							let _valor_prima = _prima_neta * (1.0 / 100);
							let _porcentaje = 1.0;
						end if

					end if

				   	if _porcentaje <> 0 then

						SELECT  cod_subramo,
								cod_origen,
								cod_contratante
						   INTO _cod_subramo,
								_cod_origen,
								_cod_contr
						   FROM emipomae
						  WHERE no_poliza = _no_poliza;

					    SELECT nombre
					      INTO v_nombre_clte
					      FROM cliclien
					     WHERE cod_cliente = _cod_contr;

						INSERT INTO chqfidel(
						cod_agente,
						no_poliza,
						prima_neta,
						comision,
						nombre,
						no_documento,
						no_licencia,
						seleccionado,
						periodo,
						fecha_genera,
						cod_ramo,
						cod_subramo,
						cod_origen,
						nombre_cte,
						por_persistencia,
						porcentaje)
					    VALUES (
					    _cod_agente,
						_no_poliza,
						_prima_neta,
						_valor_prima,
						_nombre,
						_no_documento,
						_no_licencia,
						0,
						a_periodo,
						current,
						_cod_ramo,
						_cod_subramo,
						_cod_origen,
						v_nombre_clte,
						_valor,
						_porcentaje);

				  	end if

					update incent08
					   set por_persistencia = _valor,
					       porcentaje		= _porcentaje
					 where periodo          = a_periodo
					   and cod_agente       = _cod_agente
					   and cod_ramo         = _cod_ramo
					   and no_poliza        = _no_poliza;					

			    end foreach
		end foreach

end foreach

foreach

	SELECT cod_agente
	  INTO _cod_agente
	  FROM chqfidel
     WHERE periodo = a_periodo
	 GROUP BY cod_agente
	 ORDER BY cod_agente

 	call sp_che92(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;

	if _error <> 0 then
		return _error,'Actualizacion Exitosa...',_cod_ramo;
	end if

end foreach

update parparam
   set ult_per_fidel = a_periodo
 where cod_compania  = a_compania;

end
return 0, 'Actualizacion Exitosa...',_cod_ramo;

END PROCEDURE;