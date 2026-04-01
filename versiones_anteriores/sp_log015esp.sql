-- Reporte para correo certificado agrupados -- Sacado del reporte de de Aviso de Cancelacion 
-- Creado    : 15/01/2015 - Autor: Amado Perez 
-- SIS v.2.0 - d_cobr_sp_cob748c_dw1 - DEIVID, S.A.  -- x corredor 
-- SIS v.2.0 - d_cobr_sp_cob748h_dw1 - DEIVID, S.A.	 -- x acreedor 
 
 DROP PROCEDURE sp_log015_e; 
CREATE PROCEDURE "informix".sp_log015_e(a_compania CHAR(3),a_cobrador CHAR(3) DEFAULT '*',a_tipo_aviso SMALLINT,a_agente CHAR(5) DEFAULT '*',a_acreedor CHAR(5) DEFAULT '*', a_asegurado CHAR(10) DEFAULT '*',a_callcenter SMALLINT DEFAULT 0, a_referencia varchar(255) default "*",a_fecha0 date)
RETURNING   CHAR(15),          -- no_aviso
			varchar(10),       -- espacio
            VARCHAR(50),       -- destinatario
			varchar(20),       -- valor de franqueo
            VARCHAR(50),       -- estafeta
            CHAR(20), 		   -- no_documento
		    CHAR(100), 		   -- nombre_cliente
			CHAR(50),          -- Cobrador
			varchar(20),       -- estado
			INTEGER,		   -- Salto de pagina
			varchar(10),       -- numero
			varchar(255);      -- filtro

DEFINE _compania_nombre 	CHAR(50);
DEFINE _nombre_cobrador 	CHAR(50);
define _no_aviso 			CHAR(15);
define _codigo              char(25);
define _no_documento 		CHAR(20);
define _no_poliza 			CHAR(10);
define _periodo 			CHAR(7);
define _vigencia_inic 		DATE;
define _vigencia_final 	    DATE;
define _cod_ramo 			CHAR(3);
define _nombre_ramo 		CHAR(50);
define _nombre_subramo 	    CHAR(50);
define _cedula 				CHAR(10);
define _nombre_cliente 	    CHAR(100);
define _saldo 				DECIMAL(16,2);
define _por_vencer 			DECIMAL(16,2);
define _exigible 			DECIMAL(16,2);
define _corriente 			DECIMAL(16,2);
define _dias_30 			DECIMAL(16,2);
define _dias_60 			DECIMAL(16,2);
define _dias_90 			DECIMAL(16,2);
define _dias_120 			DECIMAL(16,2);
define _dias_150 			DECIMAL(16,2);
define _dias_180 			DECIMAL(16,2);
define _cod_acreedor 		CHAR(10); --CHAR(5);HGP 12032019
define _nombre_acreedor 	CHAR(50);
define _cod_agente 			CHAR(5);
define _nombre_agente 		CHAR(50);
define _porcentaje 			DECIMAL(16,2);
define _telefono 			CHAR(10);
define _cod_cobrador 		CHAR(3);
define _cod_vendedor 		CHAR(3);
define _apartado 			CHAR(20);
define _fax_cli 			CHAR(10);
define _tel1_cli 			CHAR(10);
define _tel2_cli 			CHAR(10);
define _apart_cli 			CHAR(20);
define _email_cli 			CHAR(50);
define _fecha_proc 			DATE;
define _cobra_poliza	 	CHAR(1);
define _estatus_poliza	 	CHAR(1);
DEFINE _cod_formapag    	CHAR(3);
DEFINE _nombre_formapag 	CHAR(50);
DEFINE _no_factura      	CHAR(10);
Define _mes_char		    CHAR(2);
Define _ano_char		    CHAR(4);

DEFINE _fecha_actual	   DATE;
DEFINE _periodo_c		   CHAR(7);
DEFINE _saldo_c   		   DECIMAL(16,2);
define _corriente_c 	   DECIMAL(16,2);
DEFINE _por_vencer_c	   DECIMAL(16,2);
DEFINE _exigible_c		   DECIMAL(16,2);
DEFINE _dias_30_c		   DECIMAL(16,2);
DEFINE _dias_60_c		   DECIMAL(16,2);
DEFINE _dias_90_c		   DECIMAL(16,2);
DEFINE _dias_120_c		   DECIMAL(16,2);
DEFINE _dias_150_c 		   DECIMAL(16,2);
DEFINE _dias_180_c		   DECIMAL(16,2);

DEFINE _cod_contratante    CHAR(10);
DEFINE _direccion_1        VARCHAR(50);
DEFINE _cod_estafeta       CHAR(4);
DEFINE _estafeta           VARCHAR(50);
DEFINE _salto_pag          INTEGER;
DEFINE _cont_filas         INTEGER;
DEFINE _nombre_estafeta    CHAR(50);

DEFINE _numero		        varchar(10);
DEFINE _valor_franqueo		varchar(20);
DEFINE _estado      		varchar(20);
DEFINE _espacio		        varchar(10);

define __numero 			CHAR(15);
DEFINE __destinatario       VARCHAR(50);
define __poliza 		    CHAR(20);
define __asegurado 	        CHAR(100);
DEFINE __usuario 	        CHAR(50);

define v_filtros            varchar(255);
define _tipo	            char(1);
define _renglon             smallint; -- 32, 767 to 32, 767
DEFINE _siguiente           INTEGER;
DEFINE _siguiente_char      CHAR(10); 
DEFINE _correo_certif       CHAR(150); 
define _no_aviso_new 		CHAR(15); 
define a_numero             char(150); 
define a_buscar             char(150); 
define a_marcar_entrega     smallint; 
define _marcar_certifica    smallint; 
define _avi_so              CHAR(5);
define _completo            VARCHAR(255);
define _len_string          smallint; 
define _reporte_certifica   varchar(10); 


SET ISOLATION TO DIRTY READ; 

drop table if exists tmp_codigos; 
drop table if exists tmp_ccert; 
drop table if exists tmp_reporte; 

  -- Control Impresiones 
  --drop table if exists tmp_ccert; 
create temp table tmp_ccert( 
id_aviso	    char(15)  not null, 
id_poliza	    char(20)  not null, 
id_renglon	    smallint  not null, 
salto_pag		INTEGER, 
numero			varchar(10), 
primary key (id_aviso,id_poliza,id_renglon)) with no log; 

-- Control Impresiones 
-- Drop table if exists tmp_reporte; 
create temp table tmp_reporte( 
id_aviso        CHAR(15),          -- no_aviso 
espacio			varchar(10),       -- espacio 
destinatario	VARCHAR(50),       -- destinatario 
valor_franqueo	varchar(20),       -- valor de franqueo 
estafeta		VARCHAR(50),       -- estafeta 
poliza			CHAR(20), 		   -- no_documento 
asegurado		CHAR(100), 		   -- nombre_cliente 
usuario			CHAR(50),          -- Cobrador 
estado			varchar(20),       -- Estado 
salto_pag		INTEGER,		   -- Salto de pagina 
numero			varchar(10),       -- Numero 
filtros			varchar(255),      -- Filtro 
primary key (id_aviso,poliza,numero)) with no log; 

let v_filtros        = "";
let _siguiente       = 0;
let _siguiente_char  = "00000";
let a_buscar = "";
let a_numero = ""; 
let _completo = "";
let _marcar_certifica = 0;
let _reporte_certifica = "";

--set debug file to "sp_log015.trc"; 
--trace on;

if a_tipo_aviso = '6' then 
	select trim(correo_certif) 
	  into a_buscar 
	  from cobccert0 
	 where numero = a_referencia;
	 
	foreach
		select distinct(no_aviso)
		  into _avi_so
		  from avisocanc 
		 where reporte_certifica = a_referencia 
		   and imp_aviso_log = 3 
           and marcar_certifica = 1  		   
		 order by no_aviso asc	
		 
		 let _completo = trim(_completo) ||trim(cast(_avi_so as char(5)))||",";
		 
	 end foreach	 
	 --let _len_string = length(_completo)-1;
	 --let a_buscar   = _completo[1,_len_string];
     --let a_buscar   = a_buscar||";";
	 let _completo = trim(_completo)||";";
	 let a_buscar   = trim(_completo);
	 
	 let a_numero = trim(a_referencia);
	 let a_referencia = trim(a_buscar);	 
end if

if a_tipo_aviso = '0' then 
	foreach
		select distinct(no_aviso)
		  into _avi_so
		  from avisocanc 
		 where ejecuto = 1 
		   and reporte_certifica is not null
	       and fecha_certifica = a_fecha0
		   and marcar_certifica = 2
		 order by no_aviso asc	
		 
		 let _completo = trim(_completo) ||trim(cast(_avi_so as char(5)))||",";
		 
	 end foreach	 

	 let _completo = trim(_completo)||";";
	 let a_buscar   = trim(_completo);
	 
	 let a_numero = trim(a_referencia);
	 let a_referencia = trim(a_buscar);	 
end if


LET v_filtros = TRIM(v_filtros) ||" No.Avisos: "||TRIM(a_referencia);
LET _tipo = sp_sis04(a_referencia); -- Separa los valores del String

IF a_agente = '%'	THEN
	LET a_agente = '*';
END IF
IF a_acreedor = '%'	THEN
	LET a_acreedor = '*';
END IF
IF a_asegurado = '%'	THEN
	LET a_asegurado = '*';
END IF
IF a_cobrador = '%'	THEN
	LET a_cobrador = '*';
END IF

-- Nombre de la Compania
LET  _compania_nombre = sp_sis01(a_compania);

if a_callcenter = 0 then
	let _cobra_poliza = "C";
else
	let _cobra_poliza = "E";
end if
--
let _fecha_actual = today;
let _periodo_c	        = ' ';
let _numero	            = ' ';
let _valor_franqueo	    = ' ';
let _estado	            = 'EN TRAMITE';
let _espacio	        = ' ';
let a_marcar_entrega    = 0;

IF MONTH(_fecha_actual) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_actual);
ELSE
	LET _mes_char = MONTH(_fecha_actual);
END IF

LET _ano_char = YEAR(_fecha_actual);
LET _periodo_c  = _ano_char || "-" || _mes_char;

let _salto_pag = 0;
let _cont_filas = 0;

--set debug file to "sp_log015.trc";
--trace on;

-- Reporte de las Cartas a Imprimir
{foreach
	SELECT codigo 
	into _codigo
	FROM tmp_codigos
	order by codigo asc}
	
FOREACH
  SELECT no_aviso,
         no_documento,
         no_poliza,
         periodo,
         vigencia_inic,
         vigencia_final,
         cod_ramo,
         nombre_ramo,
         nombre_subramo,
         cedula,
         nombre_cliente,
         saldo,
         por_vencer,
         exigible,
         corriente,
         dias_30,
         dias_60,
         dias_90,
         dias_120,
         dias_150,
         dias_180,
         cod_acreedor,
         nombre_acreedor,
         cod_agente,
         nombre_agente,
         porcentaje,
         telefono,
         cod_cobrador,
         cod_vendedor,
         apartado,
         fax_cli,
         tel1_cli,
         tel2_cli,
         apart_cli,
         email_cli,
         fecha_proceso,
		 cod_formapag,
		 nombre_formapag,
		 cobra_poliza,
		 estatus_poliza,
		 no_factura,
         cod_contratante,
         renglon,
		 marcar_entrega,
         marcar_certifica,
         reporte_certifica		 
  into  _no_aviso,
         _no_documento,
         _no_poliza,
         _periodo,
         _vigencia_inic,
         _vigencia_final,
         _cod_ramo,
         _nombre_ramo,
         _nombre_subramo,
         _cedula,
         _nombre_cliente,
         _saldo,
         _por_vencer,
         _exigible,
         _corriente,
         _dias_30,
         _dias_60,
         _dias_90,
         _dias_120,
         _dias_150,
         _dias_180,
         _cod_acreedor,
         _nombre_acreedor,
         _cod_agente,
         _nombre_agente,
         _porcentaje,
         _telefono,
         _cod_cobrador,
         _cod_vendedor,
         _apartado,
         _fax_cli,
         _tel1_cli,
         _tel2_cli,
         _apart_cli,
         _email_cli,
         _fecha_proc,
		 _cod_formapag,
		 _nombre_formapag,
		 _cobra_poliza,
		 _estatus_poliza,
		 _no_factura,
		 _cod_contratante,
         _renglon,
		 a_marcar_entrega,
		 _marcar_certifica,
		 _reporte_certifica
    FROM avisocanc
   WHERE ejecuto = 1 and reporte_certifica is not null
	 and fecha_certifica = a_fecha0 and marcar_certifica = 2
	 and cod_agente   MATCHES a_agente
	 AND cod_acreedor MATCHES a_acreedor
	 AND cedula  	  MATCHES a_asegurado
	 AND cod_cobrador MATCHES a_cobrador
--	 AND desmarca = 1
--     and marcar_entrega <> 1  -- 30/5/2016 si se entrego no mostrarlo 
	 --and estatus <> 'Y'
	 and imp_aviso_log = '3'    -- Correccion ya que salian incluso sin haber sido impreso 4/8/16 Henry
   ORDER BY no_aviso, nombre_cliente, no_documento
   
   if _marcar_certifica is null then
       let _marcar_certifica = 0;
   end if

	if a_tipo_aviso = '6' then
		let a_buscar = "";
		select count(*)
		  into a_buscar
		  from cobccert1
		 where numero  = a_numero 
		   and no_documento = _no_documento
		   and error <> '1';	 	 	  	 
		 
		 if a_buscar = "" or a_buscar is null then
			continue foreach;
		 end if	 
		 
	    if _reporte_certifica <> a_numero then
			continue foreach;
		end if
   
	else
		--if a_marcar_entrega <> 0 then  -- ( marcar_entrega <> 0 ) and ( marcar_entrega <> 1 ) 		
		if _marcar_certifica not in (2) then
			continue foreach;
		end if
	end if

   	{	
	CALL sp_cob245("001","001",_no_documento,_periodo_c,_fecha_actual) 
		 		   	 RETURNING _por_vencer_c,
							   _exigible_c,
							   _corriente_c,
							   _dias_30_c,
							   _dias_60_c,
							   _dias_90_c,
							   _dias_120_c,
							   _dias_150_c,
							   _dias_180_c,
							   _saldo_c;
	  IF _saldo_c = 0 then
		 continue foreach;
	  end if	  
	 }

  -- Usuario que generar la campania
  SELECT user_added
    INTO _nombre_cobrador
    FROM avicanpar
   WHERE cod_avican = _no_aviso;

  -- Dirección del cliente y estafeta
  SELECT direccion_1, cod_estafeta
    INTO _direccion_1, _cod_estafeta
    FROM cliclien
   WHERE cod_cliente = _cod_contratante;

  LET _estafeta = NULL;

  IF _cod_estafeta IS NOT NULL AND TRIM(_cod_estafeta) <> "" THEN
	SELECT nombre
	  INTO _nombre_estafeta
	  FROM cobestafeta
	 WHERE cod_estafeta = _cod_estafeta;

	LET _estafeta = "ENTREGA GENERAL " || _cod_estafeta || " " || _nombre_estafeta;	
  END IF


  LET _cont_filas = _cont_filas + 1;
  	IF _salto_pag > 17  THEN  -- limite de 500 registros: 28 + 30 * 15 + 22 
		--exit FOREACH;
	ELSE
		IF _salto_pag = 0 and _cont_filas = 29 THEN
			LET _cont_filas = 1;
			LET _salto_pag = _salto_pag + 1;
		ELSE
			IF _salto_pag = 16 and _cont_filas = 23 THEN
				LET _cont_filas = 1;
				LET _salto_pag = _salto_pag + 1;
			ELSE
				IF _cont_filas = 31 THEN
					LET _cont_filas = 1;
					LET _salto_pag = _salto_pag + 1;
				END IF
			END IF
		END IF
	END IF
  let __numero = _no_aviso;
  let __destinatario = ""; --_direccion_1; 
  let __poliza = _no_documento;
  let __asegurado = _nombre_cliente;

  -- Usuario que genera el aviso
  SELECT user_added
    INTO __usuario
    FROM avicanpar
   WHERE cod_avican = _no_aviso;
 -- let __usuario = _nombre_cobrador;
	IF _salto_pag < 17  THEN
		insert into tmp_ccert(id_aviso,id_poliza,id_renglon,salto_pag,numero)
		values(_no_aviso,_no_documento,_renglon,_salto_pag,_cont_filas);
      	--if _no_aviso_new <> _no_aviso and _no_aviso_new <> "0" then
	    --   continue foreach;
	    --end if 
        let _no_aviso_new = _no_aviso;
		let _numero = _renglon;
		insert into tmp_reporte(
				id_aviso,
				espacio,
				destinatario,
				valor_franqueo,
				estafeta,
				poliza,
				asegurado,
				usuario,
				estado,
				salto_pag,
				numero,
				filtros	)
		values(__numero,
			   _espacio,
			   __destinatario,
			   _valor_franqueo,
			   _estafeta,
			   __poliza,
			   __asegurado,
			   __usuario,
			   _estado,
			   _salto_pag,
			   _numero,
			   v_filtros);

		{RETURN __numero,
			   _espacio,
			   __destinatario, --_direccion_1,
			   _valor_franqueo,
			   _estafeta,
			   __poliza,   	-- no_documento
			   __asegurado, 	-- n_cliente
			   __usuario,    -- n_cobrador
			   _estado,
			   _salto_pag,
			   _numero,
			   v_filtros
			   WITH RESUME;	 		}
	else
			   Exit foreach;
	End If

END FOREACH
 
 --end foreach  
--trace on; 

if a_tipo_aviso <> '6' then 

	let _no_aviso_new = "0"; 
	let _siguiente = 2; 
		
		select valor_parametro 
		   into _siguiente 
		   from parcont 
		  where cod_parametro = 'cob_entrega'; 
		  if _siguiente is null then 
			let _siguiente = 0; 
		  end if
		let _siguiente = _siguiente + 1; 
		IF _siguiente > 9999 THEN 
			LET _siguiente_char = _siguiente;
		ELIF _siguiente > 999 THEN
			LET _siguiente_char[2,5] = _siguiente;
		ELIF _siguiente > 99  THEN
			LET _siguiente_char[3,5] = _siguiente;
		ELIF _siguiente > 9  THEN
			LET _siguiente_char[4,5] = _siguiente;
		ELSE
			LET _siguiente_char[5,5] = _siguiente;
		END IF
		
		 let _correo_certif = a_referencia[1,150]; 
		 --let _siguiente_char = "00002";
		 -- se habilitara cuando se valla a correr el parcont
		 insert into cobccert0(numero,correo_certif,no_aviso,fecha_adicion,fecha_recibo,usuario_captura,activo,usuario_entrega)	 
		 values(_siguiente_char,_correo_certif,_no_aviso_new,CURRENT,CURRENT,"informix","4","informix") ;	-- 4 estado de reporte logistica  

	FOREACH
		select distinct trim(id_aviso)
		  into _no_aviso
		  from tmp_ccert
		  --order by id_aviso
		  
		  --order by salto_pag,numero

		  --(id_aviso,id_poliza,id_renglon) 
		  --values(_no_aviso,_no_documento,_renglon) ;
		  --Actualiza cobccert0,cobccert1 y parcont[cob_entrega]

		FOREACH
			select distinct trim(id_poliza) --,id_renglon
			into _no_documento --,_renglon
			  from tmp_ccert
			  where id_aviso = _no_aviso
			   --order by salto_pag,numero

			  insert into cobccert1(numero,no_documento,error)
			  values(_siguiente_char,_no_documento,2);  -- 2 no visualizar

		END FOREACH
		
	END FOREACH	 
	
	UPDATE parcont
	   SET valor_parametro = _siguiente_char
	 WHERE cod_parametro   = 'cob_entrega';
	 let _fecha_actual  = sp_sis26(); 
	 
	FOREACH
		select trim(id_aviso),trim(id_poliza)  
		into __numero, _no_documento  
		  from tmp_ccert 

		  update avisocanc 
			  --set marcar_entrega = 2,impreso = _siguiente, fecha_marcar = _fecha_actual 
			  --set marcar_certifica = 1,reporte_certifica = _siguiente, fecha_certifica = _fecha_actual, user_certifica = user_imp_aviso_log 
				set marcar_certifica = 2,reporte_certifica = _siguiente_char --, fecha_certifica = _fecha_actual, user_certifica = user_imp_aviso_log 		  		  
			where no_aviso = __numero and no_documento = _no_documento; 

	END FOREACH		 
else
	let _siguiente_char    = a_numero;	 
end if	 

--trace off;


FOREACH
	 	select id_aviso,
				espacio,
				destinatario,
				valor_franqueo,
				estafeta,
				poliza,
				asegurado,
				usuario,
				estado,
				salto_pag,
				numero,
				filtros
	      into __numero,
			   _espacio,
			   __destinatario,
			   _valor_franqueo,
			   _estafeta,
			   __poliza,
			   __asegurado,
			   __usuario,
			   _estado,
			   _salto_pag,
			   _numero,
			   v_filtros
	      from tmp_reporte
		  --order by id_aviso,asegurado		  

		RETURN __numero,
			   _espacio,
			   __destinatario,
			   _valor_franqueo,
			   _estafeta,
			   __poliza,
			   __asegurado,
			   __usuario,
			   _estado,
			   _salto_pag,
			   _siguiente_char, --_numero,
			   v_filtros
			   WITH RESUME;
END FOREACH
--trace off;

drop table if exists tmp_codigos;
drop table if exists tmp_ccert;
drop table if exists tmp_reporte;

END PROCEDURE
