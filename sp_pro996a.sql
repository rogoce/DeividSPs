-- Pool automatico, informe de renovacion para notificacion a corredores
-- Creado : 12/05/2010 - Autor: Armando Moreno M.
-- Modificado: 	15/09/2010 - Autor: Roman Gordon     Se adiciono el filtro por Zona y Sucursal
-- SIS v.2.0 - d_prod_sp_pro996_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro996a;
CREATE PROCEDURE "informix".sp_pro996a(a_sucursal char(3), a_periodo char(7), a_codramo char(255) default "*", a_codsuc char(255) default "*", a_codvend char(255) default "*")
returning varchar(50),	 -- n_corredor
		  char(10),		 -- no_poliza
		  char(8),		 -- user_added
		  char(3),       -- cod_no_renov
		  char(20),		 -- no_documento
		  smallint,		 -- renovar
		  smallint,		 -- no_renovar
		  date,			 -- fecha_selec
		  date,			 -- vigencia_inic
		  date,			 -- vigencia_final
		  dec(16,2),	 -- saldo
		  smallint,		 -- cant_reclamos
		  char(10),		 -- no_factura 
		  decimal(16,2), -- incurrido   
		  decimal(16,2), -- pagos   
		  decimal(5,2),	 -- porc_depreciacion
		  char(5),	   	 -- cod_agente
		  varchar(100),  -- n_cliente
		  char(10),		 -- cod_contratante  
		  smallint,		 -- estatus
		  char(3),	     -- cod_sucursal
		  CHAR(50),		 -- ramo
		  CHAR(50),		 -- telefono
		  CHAR(50),		 -- compania
		  CHAR(50),      -- sucursal
		  SMALLINT,		 -- conoce
		  CHAR(15),		 -- mes
		  CHAR(50),      -- nombre vendedor
		  CHAR(255);     -- filtros


define _nombre_vendedor		char(50);
define _incurrido			decimal(16,2);    
define _pagos		        decimal(16,2); 
define _porc_depreciacion   decimal(5,2);  	
define _no_factura			char(10);
define _cant_reclamos		smallint;
define _saldo				dec(16,2);
define _fecha_selec			date;
define _cod_no_renov		char(3);
define _renovar				char(3);
define _no_renovar			char(3);
define _no_poliza	    	char(10);	 
define _cod_contratante 	char(10);	 
define _user_added   		char(8);
define _no_documento		char(20);
define _vigencia_inic		date;
define _vigencia_final		date;
define _cod_agente  		char(5);
define _saldo_porc      	integer;
define _n_cliente       	varchar(100);
define _n_corredor      	varchar(50);
define _fecha_hoy       	date;
define _estatus         	smallint;
define _nom_sucursal		char(50);
define _sucursal        	char(3);
define _cod_ramo        	char(3);
define _suc_prom        	char(3);
define _cod_vendedor		char(3);
DEFINE v_nombre_ramo   	 	CHAR(50);
DEFINE v_telefono   	 	CHAR(50);
DEFINE v_compania   	 	CHAR(50);
DEFINE v_sucursal   	 	CHAR(50);

DEFINE v_tel1			 	CHAR(10);
DEFINE v_tel2			 	CHAR(10);
DEFINE v_tel3			 	CHAR(10);
DEFINE v_celular	  	 	CHAR(10);
DEFINE v_conoce          	smallint;
DEFINE ls_fecha_letra    	CHAR(15);
DEFINE _cantidad          	smallint;
DEFINE v_filtros            CHAR(255);
DEFINE _tipo                CHAR(01);
define _cnt                 smallint;
define _tipo_agente         char(1);
DEFINE _fecha1  		 DATE;
DEFINE _fecha2	 		 DATE;
DEFINE _mes1     		 SMALLINT;
DEFINE _mes2     	     SMALLINT;
DEFINE _ano1     	     SMALLINT;
DEFINE _ano2     		 SMALLINT;


begin

Create Temp Table tmp_pool(
	 n_corredor 	   varchar(50),	 -- n_corredor
     no_poliza 		   char(10),	 -- no_poliza
	 user_added 	   char(8),		 -- user_added
	 cod_no_renov 	   char(3),      -- cod_no_renov
	 no_documento 	   char(20),	 -- no_documento
	 renovar 		   smallint,	 -- renovar
	 no_renovar 	   smallint,	 -- no_renovar
	 fecha_selec 	   date,		 -- fecha_selec
	 vigencia_inic 	   date,		 -- vigencia_inic
	 vigencia_final    date,		 -- vigencia_final
	 saldo 			   dec(16,2),	 -- saldo
	 cant_reclamos     smallint,	 -- cant_reclamos
	 no_factura 	   char(10),	 -- no_factura 
	 incurrido 		   decimal(16,2),-- incurrido   
	 pagos 			   decimal(16,2),-- pagos   
	 porc_depreciacion decimal(5,2), -- porc_depreciacion
	 cod_agente 	   char(5),	   	 -- cod_agente
	 n_cliente 		   varchar(100), -- n_cliente
	 cod_contratante   char(10),	 -- cod_contratante  
	 estatus 		   smallint,	 -- estatus
	 cod_sucursal	   char(3),	     -- cod_sucursal
	 cod_ramo 		   char(3),		 -- cod_ramo
	 ramo 			   CHAR(50),	 -- ramo
	 telefono 		   CHAR(50),	 -- telefono
	 compania 		   CHAR(50),	 -- compania
	 sucursal 		   CHAR(50),     -- sucursal
	 conoce 		   SMALLINT,	 -- conoce
	 mes 			   CHAR(15),	 -- mes
	 cod_vendedor	   char(3),      -- cod_vendedor
	 nombre_vendedor   char(50),     -- nombre vendedor
	 seleccionado	   smallint		 -- seleccionado
	 ) With No Log;

let v_nombre_ramo = '';
let v_telefono = '';
let v_compania = '';
let v_sucursal = '';

-- Descomponer los periodos en fechas
LET _ano1 = a_periodo[1,4];
LET _mes1 = a_periodo[6,7];

LET _ano2 = a_periodo[1,4];
LET _mes2 = a_periodo[6,7];

LET _mes1 = _mes1;
LET _fecha1 = MDY(_mes1,1,_ano1);

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;


SET ISOLATION TO DIRTY READ;

LET v_compania  = sp_sis01("001");

SELECT trim(descripcion)
  INTO v_sucursal
  FROM insagen
 WHERE codigo_agencia  = a_sucursal
   AND codigo_compania = "001";

let _fecha_hoy = current;

--set debug file to "sp_pro996a.trc";	  	  	  	
--trace on;
LET v_filtros="";

foreach

	SELECT no_poliza, 
		   sucursal_origen, 
		   user_added,
		   no_documento, 
		   cod_contratante, 
		   vigencia_final, 
		   vigencia_inic,
		   cod_ramo
	  INTO _no_poliza, 
	  	   _sucursal, 
	  	   _user_added,
		   _no_documento, 
		   _cod_contratante, 
		   _vigencia_final, 
		   _vigencia_inic,
		   _cod_ramo
	  FROM emipomae
	 WHERE vigencia_final >= _fecha1
	   AND vigencia_final <= _fecha2
	   AND actualizado = 1
	   AND renovada    = 0
	   AND no_renovar  = 0
	   AND incobrable  = 0
	   AND abierta     = 0
	   AND estatus_poliza IN (1,3)

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		exit foreach;
	end foreach

	let _cantidad = 0;

	--IF a_codramo <> "*" THEN   -- filtro solicitado

	  --	SELECT count(*)
		--  INTO _cantidad
		  --FROM tmp_codigos
		 --WHERE trim(codigo) IN (trim(_cod_ramo));

		 --if _tipo <> "E" then
		   --if _cantidad = 0 then
			 --CONTINUE FOREACH;
		   --end if
	 	--else
		   --if _cantidad = 1 then
		 --		CONTINUE FOREACH;
		 --end if
	--end if

	--END IF

	select sucursal_promotoria,trim(descripcion)
	  into _suc_prom,_nom_sucursal
	  from insagen
	 where codigo_agencia  = _sucursal
	   and codigo_compania = '001';

 
	select cod_vendedor
	  into _cod_vendedor
	  from parpromo
	 where cod_agente  = _cod_agente
	   and cod_agencia = _suc_prom
	   and cod_ramo	   = _cod_ramo;
	
	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;

	--Selecciona los nombres de Ramos

	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	let v_conoce = 0;
	--Selecciona los nombres de Clientes

	SELECT nombre,telefono1,telefono2 ,telefono3, celular, conoce_cliente
	  INTO _n_cliente,v_tel1,v_tel2,v_tel3,v_celular,v_conoce
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante ;

	let v_telefono = ''; 
	if v_celular is not null then
		let v_telefono = trim(v_celular)||'/'||trim(v_telefono) ;  
	end if	
	if  v_tel3 is not null then
		let v_telefono = trim(v_tel3)||'/'||trim(v_telefono) ; 
	end if
	if  v_tel2 is not null then
		let v_telefono = trim(v_tel2)||'/'||trim(v_telefono) ; 
	end if
	if  v_tel1 is not null then
		let v_telefono = trim(v_tel1)||'/'||trim(v_telefono) ; 
	end if	  
	if v_telefono is null then
		let v_telefono  = ''; 
	end if	

	SELECT nombre,
	       tipo_agente
	  INTO _n_corredor,
	       _tipo_agente
	  FROM agtagent
     WHERE cod_agente = _cod_agente;

	if _tipo_agente not in("O") then
		continue foreach;
	end if

	IF _mes1 = 1 THEN
	  LET ls_fecha_letra = 'enero';
	ELIF _mes1 = 2 THEN
	  LET ls_fecha_letra = 'febrero';
	ELIF _mes1 = 3 THEN
	  LET ls_fecha_letra = 'marzo';
	ELIF _mes1 = 4 THEN
	  LET ls_fecha_letra = 'abril';
	ELIF _mes1 = 5 THEN
	  LET ls_fecha_letra = 'mayo';
	ELIF _mes1 = 6 THEN
	  LET ls_fecha_letra = 'junio';
	ELIF _mes1 = 7 THEN
	  LET ls_fecha_letra = 'julio';
	ELIF _mes1 = 8 THEN
	  LET ls_fecha_letra = 'agosto';
	ELIF _mes1 = 9 THEN
	  LET ls_fecha_letra = 'septiembre';
	ELIF _mes1 = 10 THEN
	  LET ls_fecha_letra = 'octubre';
	ELIF _mes1 = 11 THEN
	  LET ls_fecha_letra = 'noviembre';
	ELIF _mes1 = 12 THEN
	  LET ls_fecha_letra = 'diciembre';
	END IF

   if v_conoce is null then
	   let v_conoce = 0;	
   end if
   if v_conoce = 1 then
		continue foreach;
   end if

   Insert into tmp_pool(
   	 n_corredor, 	   
     no_poliza, 		   
	 user_added, 	   
	 cod_no_renov, 	   
	 no_documento, 	   
	 renovar, 		   
	 no_renovar, 	   
	 fecha_selec, 	   
	 vigencia_inic, 	   
	 vigencia_final,    
	 saldo, 			   
	 cant_reclamos,
	 no_factura,    
	 incurrido,	      
	 pagos,	      
	 porc_depreciacion,
	 cod_agente,
	 n_cliente,	   
	 cod_contratante,
	 estatus,  
	 cod_sucursal,
	 cod_ramo,   
	 ramo,	   
	 telefono,
	 compania,		   
	 sucursal,		   
	 conoce,	   
	 mes,		   
	 cod_vendedor,
	 nombre_vendedor,
	 seleccionado   
   )
   
   Values(
   	 _n_corredor,
   	 _no_poliza,
   	 _user_added,   
   	 "",   
	 _no_documento,   
	 0,   
	 0,   
	 '01/01/1900',   
	 _vigencia_inic,   
	 _vigencia_final,   
	 0,   
	 0,   
	 "",   
	 0,   
	 0,   
	 0,
	 _cod_agente,
	 _n_cliente,
	 _cod_contratante,
	 0,
	 _sucursal,
	 _cod_ramo,
	 v_nombre_ramo,
	 v_telefono,
	 v_compania,
	 _nom_sucursal,
	 v_conoce,
	 ls_fecha_letra,
	 _cod_vendedor,
	 _nombre_vendedor,
	 1
	);
	 
end foreach

IF a_codramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_codramo);

	LET _tipo = sp_sis04(a_codramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

	   UPDATE tmp_pool
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

	   UPDATE tmp_pool
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


LET _tipo = "";
--Filtro por Zona
IF a_codvend <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Zona "||TRIM(a_codvend);
	LET _tipo = sp_sis04(a_codvend); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE tmp_pool
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_vendedor NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE tmp_pool
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_vendedor IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF

LET _tipo = "";
--Filtro por Sucursal
IF a_codsuc <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_codsuc);
	LET _tipo = sp_sis04(a_codsuc); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
	   UPDATE tmp_pool
	      SET seleccionado = 0
	    WHERE seleccionado = 1
	      AND cod_sucursal NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
	   UPDATE tmp_pool
	      SET seleccionado = 0
	    WHERE seleccionado = 1
	      AND cod_sucursal IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF

foreach with hold

select n_corredor, 	   
       no_poliza, 		   
	   user_added, 	   
	   cod_no_renov, 	   
	   no_documento, 	   
	   renovar, 		   
	   no_renovar, 	   
	   fecha_selec, 	   
	   vigencia_inic, 	   
	   vigencia_final,    
	   saldo, 			   
	   cant_reclamos,
	   no_factura,    
	   incurrido,	      
	   pagos,	      
	   porc_depreciacion,
	   cod_agente,
	   n_cliente,	   
	   cod_contratante,
	   estatus,  
	   cod_sucursal,
	   ramo,	   
	   telefono,
	   compania,		   
	   sucursal,		   
	   conoce,	   
	   mes,
	   nombre_vendedor
  into _n_corredor,
  	   _no_poliza,		   
	   _user_added,
	   _cod_no_renov,
	   _no_documento,
	   _renovar,
	   _no_renovar,
	   _fecha_selec,
	   _vigencia_inic,
	   _vigencia_final,
	   _saldo,
	   _cant_reclamos,
	   _no_factura,
	   _incurrido,
	   _pagos,
	   _porc_depreciacion,
	   _cod_agente,
	   _n_cliente,
	   _cod_contratante,
	   _estatus,
	   _sucursal,
	   v_nombre_ramo,
	   v_telefono,
	   v_compania,
	   _nom_sucursal,
	   v_conoce,
	   ls_fecha_letra,
	   _nombre_vendedor
  from tmp_pool
 where seleccionado = 1
	   
return _n_corredor,
  	   _no_poliza,		   
	   _user_added,
	   _cod_no_renov,
	   _no_documento,
	   _renovar,
	   _no_renovar,
	   _fecha_selec,
	   _vigencia_inic,
	   _vigencia_final,
	   _saldo,
	   _cant_reclamos,
	   _no_factura,
	   _incurrido,
	   _pagos,
	   _porc_depreciacion,
	   _cod_agente,
	   _n_cliente,
	   _cod_contratante,
	   _estatus,
	   _sucursal,
	   v_nombre_ramo,
	   v_telefono,
	   v_compania,
	   _nom_sucursal,
	   v_conoce,
	   ls_fecha_letra,
	   _nombre_vendedor,
	   v_filtros		  
	   with resume;

end foreach

--COMMIT WORK;
drop table tmp_pool;
END
END PROCEDURE 