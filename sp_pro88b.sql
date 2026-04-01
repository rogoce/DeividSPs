-- Estado de Cuenta Trimestral por Contratos y por Factultativos

-- Creado    : 17/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/02/2002 - Autor: Marquelda Valdelamar

--drop procedure sp_pro88b;
Create procedure sp_pro88b(
a_compania	   CHAR(3),
a_ano	       SMALLINT
,
a_cod_coasegur CHAR(3),
a_trimestre	   SMALLINT
) RETURNING   CHAR(50),  -- Cia Coaseguradora
              CHAR(50),  -- direccion1
			  CHAR(50),  -- direccion2
			  CHAR(30),  -- tipo Contrato
			  CHAR(20),  -- trimestre
			  SMALLINT,  -- ano
			  DEC(16,2), -- saldo anterior
			  DEC(16,2), -- saldo actual
			  DEC(16,2), -- monto_trimestre
			  DEC(16,2), --	monto_remesa
			  CHAR(50);  -- Nombre Compania

DEFINE _nombre_coasegur  CHAR(50);
DEFINE _direccion_1      CHAR(50);
DEFINE _direccion_2      CHAR(50);
DEFINE _tipo_contrato    CHAR(30);
DEFINE _cod_contrato     CHAR(3);
DEFINE _trimestre        CHAR(20);
DEFINE _saldo_anterior   DECIMAL(16,2);
DEFINE _saldo_actual 	 DECIMAL(16,2);
DEFINE _monto_trimestre  DECIMAL(16,2);
DEFINE _remesa           DECIMAL(16,2);
DEFINE v_compania_nombre CHAR(50);

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Compania Coaseguradora
SELECT nombre,
       direccion_1,
	   direccion_2
  INTO _nombre_coasegur,
       _direccion_1,
	   _direccion_2
  FROM emicoase
 WHERE cod_coasegur = a_cod_coasegur;

LET _tipo_contrato = "FACULTATIVO";
-- Contrato
{SELECT cod_contrato,
        porc_partic_suma,
	    porc_partic_prima,
  INTO  _cod_contrato
        _porc_partic_suma,
	    _porc_partic_prima
  FROM  emireaco
 WHERE  cod_coasegur = a_cod_coasegur
   AND  no_poliza    = _no_poliza
   AND  no_unidad    = _no_unidad

-- Facultativo
SELECT cod_contrato,
       porc_partic_reas,
	   porc_comis_fac,
  INTO _cod_contrato,
       _porc_partic_reas,
	   _porc_comis_fac
  FROM emireafa
 WHERE cod_coasegur = a_cod_coasegur
   AND no_poliza    = _no_poliza
   AND no_unidad    = _no_unidad}

   IF a_trimestre = 1 Then
		LET _trimestre = "Primer Trimestre";
	ELIF a_trimestre = 2 Then
		LET _trimestre=  "Segundo Semestre";
	ELIF a_trimestre = 3 Then
		LET _trimestre = "Tercer Trimestre";
	ELSE
		LET _trimestre = "Cuarto Trimestre";
	END IF


   {	IF   a_trimestre = 1 then
		LET ls_periodo1 = ls_ano || "-01";
		LET ls_periodo2 = ls_ano || "-03";
	ELIF a_trimestre = 2 then
		LET ls_periodo1 = ls_ano || "-04";
		LET ls_periodo2 = ls_ano || "-06";
	ELIF a_trimestre = 3 then
		LET ls_periodo1 = ls_ano || "-07";
		LET ls_periodo2 = ls_ano || "-09";
	ELSE 
		LET ls_periodo1 = ls_ano || "-10";
		LET ls_periodo2 = ls_ano || "-12";
	END IF}

RETURN   _nombre_coasegur,
	     _direccion_1,
	     _direccion_2,
		 _tipo_contrato,
		 _trimestre,
		 a_ano,
	     0.00,  
	     0.00,
	     0.00,
	     0.00,
	     v_compania_nombre
	     WITH RESUME;

END PROCEDURE