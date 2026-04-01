-- Procedimiento que trae los clientes para programa DEICAS.

-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob101;

create procedure sp_cob101(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_cobrador CHAR(3),
a_dia INT
)
returning char(10),		--cod_cliente,
       	  char(100),	--_nombre,
	      char(100),	--_direccion,
	      char(10),		--_telefono1,
	      char(10),		--_telefono2,
	      char(10),		--_celular,
	      char(10),		--_fax,
	      char(50),		--_e_mail,
	      char(10),		--_telefono3,
	      char(20),		--_apartado,
	      char(30),		--_cedula
		  smallint,		-- dia1
		  smallint,		-- dia2
		  char(3),		-- cod_gestion
		  char(2),		-- ciudad
		  char(2),		-- distrito
		  char(5),		-- area
		  char(3),		-- pais
		  char(2),		-- prov
		  char(50),		-- contacto
		  dec(16,2),	-- a pagar
		  smallint,		-- prioridad
		  char(50);		-- ultima gestion

define _cod_cliente		char(10);
define _nombre	        char(100);
define v_documento      char(20);
define _contacto	    char(50);
define _direccion	    char(100);
define _telefono1		char(10);
define _telefono2		char(10);
define _celular			char(10);
define _telefono3		char(10);
define _fax				char(10);
define _e_mail			char(50);
define _apartado		char(20);
define _cedula			char(30);
define _dia_cobros1     smallint;
define _dia_cobros2     smallint;
define _dia_cobros3     smallint;
define _tipo_cobrador   smallint;
define _cod_gestion     char(3);
define _code_pais       char(3);
define _code_provincia	char(2);
define _code_ciudad		char(2);
define _code_distrito	char(2);
define _code_correg		char(5);
DEFINE _mes_char        CHAR(2);
DEFINE _ano_char		CHAR(4);
DEFINE _periodo         CHAR(7);
DEFINE v_por_vencer     DEC(16,2);	 
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente		DEC(16,2);
DEFINE v_monto_30		DEC(16,2);
DEFINE v_monto_60		DEC(16,2);
DEFINE v_monto_90		DEC(16,2);
DEFINE v_apagar			DEC(16,2);
DEFINE v_saldo			DEC(16,2);

define _prioridad		smallint;
define _fecha_ult_pro	date;
define _procesado		smallint;
define _ultima_gestion	char(50);

set isolation to dirty read;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(TODAY) < 10 THEN
	LET _mes_char = '0'|| MONTH(TODAY);
ELSE
	LET _mes_char = MONTH(TODAY);
END IF

LET _ano_char = YEAR(TODAY);
LET _periodo  = _ano_char || "-" || _mes_char;

select tipo_cobrador
  into _tipo_cobrador
  from cobcobra
 where cod_cobrador = a_cobrador;

if _tipo_cobrador = 7 or   -- Investigador
   _tipo_cobrador = 8 then -- Supervisor

	let _prioridad = 0;

	foreach
	 select	cod_cliente,
			cod_gestion,
			dia_cobros1,
			dia_cobros2
	   into	_cod_cliente,
			_cod_gestion,
			_dia_cobros1,
			_dia_cobros2
	   from	cascliente
	  where	cod_cobrador = a_cobrador
		and procesado    = 0
	
	 select nombre
	   into _ultima_gestion
	   from cobcages
	  where cod_gestion = _cod_gestion;

	   call sp_cas012(_cod_cliente)
	     returning _nombre,
			       _direccion,
		           _telefono1,
		           _telefono2,
		           _celular,
		           _fax,
		           _e_mail,
		           _telefono3,
		           _apartado,
		           _cedula,
		           _code_ciudad,
		           _code_distrito,
		           _code_correg,
		           _code_pais,
		           _code_provincia,
		           _contacto;

		let v_apagar = 0;

	 	foreach
		 select	no_documento
		   into	v_documento
		   from	caspoliza
		  where	cod_cliente = _cod_cliente

			CALL sp_cob33(
			a_compania,
			a_agencia,
			v_documento,
			_periodo,
			today
			) RETURNING v_por_vencer,
					    v_exigible,  
					    v_corriente, 
					    v_monto_30,  
					    v_monto_60,  
					    v_monto_90,
					    v_saldo
					    ;
	
			let v_apagar = v_apagar + v_exigible;

		end foreach

		if v_apagar = 0.00 or
		   v_saldo  = 0.00 then
			continue foreach;
		end if

		return _cod_cliente,
		       _nombre,
			   _direccion,
			   _telefono1,
			   _telefono2,
			   _celular,
			   _fax,
			   _e_mail,
			   _telefono3,
			   _apartado,
			   _cedula,
			   _dia_cobros1,
			   _dia_cobros2,
			   "",
			   _code_ciudad,
			   _code_distrito,
			   _code_correg,
			   _code_pais,
			   _code_provincia,
			   _contacto,
			   v_apagar,
			   _prioridad,
			   _ultima_gestion
			   with resume;

	end foreach

else -- Gestores

	let _prioridad = 10000;

	foreach
	 select	cod_cliente,
			cod_gestion,
			dia_cobros1,
			dia_cobros2,
			dia_cobros3,
			fecha_ult_pro
	   into	_cod_cliente,
			_cod_gestion,
			_dia_cobros1,
			_dia_cobros2,
			_dia_cobros3,
			_fecha_ult_pro
	   from	cascliente
	  where	cod_cobrador  = a_cobrador

		let _procesado = 0;

		if _dia_cobros1 = a_dia or
		   _dia_cobros2 = a_dia or
		   _dia_cobros3 = a_dia then

			let _procesado = 1;

			if _fecha_ult_pro = today then
				continue foreach;
			end if

		end if

		if _procesado = 0 then
			continue foreach;
		end if

		select nombre
	      into _ultima_gestion
	      from cobcages
	     where cod_gestion = _cod_gestion;

		call sp_cas012(_cod_cliente)
		     returning _nombre,
				       _direccion,
			           _telefono1,
			           _telefono2,
			           _celular,
			           _fax,
			           _e_mail,
			           _telefono3,
			           _apartado,
			           _cedula,
			           _code_ciudad,
			           _code_distrito,
			           _code_correg,
			           _code_pais,
			           _code_provincia,
			           _contacto;

			let v_apagar   = 0;

		    foreach
			 select	no_documento
			   into	v_documento
			   from	caspoliza
			  where	cod_cliente  = _cod_cliente

				CALL sp_cob33(
				a_compania,
				a_agencia,
				v_documento,
				_periodo,
				today
				) RETURNING v_por_vencer,
						    v_exigible,  
						    v_corriente, 
						    v_monto_30,  
						    v_monto_60,  
						    v_monto_90,
						    v_saldo
						    ;
				let v_apagar = v_apagar + v_exigible;

			end foreach

			if v_apagar  <= 0.00 then
				continue foreach;
			end if

			return _cod_cliente,
			       _nombre,
				   _direccion,
				   _telefono1,
				   _telefono2,
				   _celular,
				   _fax,
				   _e_mail,
				   _telefono3,
				   _apartado,
				   _cedula,
				   _dia_cobros1,
				   _dia_cobros2,
				   "",
				   _code_ciudad,
				   _code_distrito,
				   _code_correg,
				   _code_pais,
				   _code_provincia,
				   _contacto,
				   v_apagar,
				   _prioridad,
				   _ultima_gestion;
--				   with resume;

	end foreach

end if

end procedure
