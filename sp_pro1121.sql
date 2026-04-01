------------------------------------------------
--      EMICARTASAL6          --
--         CAMBIO DE TARIFA 2018              --
---  Amado Perez - 10/07/2025 --
------------------------------------------------
drop procedure sp_pro1121;
create procedure sp_pro1121(a_periodo char(7),
							a_imp1 smallint default 0,
							a_imp2 smallint default 0,
							a_envi1 smallint default 0,
							a_envi2 smallint default 0,
							a_envi3 smallint default 0,
							a_envi4 smallint default 0,
							a_poliza char(20) default "%",
							a_opcion smallint default 1
						   )
returning	varchar(100) as contratante,
			varchar(50)  as direccion1,
			varchar(50)  as direccion2,
			char(10)     as telefono1,
			char(10)     as telefono2,
			char(10)     as celular,
			varchar(50)  as pais,
			varchar(30)  as provincia,
			char(20)     as no_documento,
			varchar(50)  as grupo,
			date         as fecha_aniv,
			varchar(50)  as agente,
			varchar(50)  as producto_act,
			dec(16,2)    as prima_act,
			varchar(50)  as producto_nvo,
			dec(16,2)    as prima_nvo,
			varchar(20)  as f_autoriza,
			varchar(50)  as firma,
			varchar(50)  as cargo,
			varchar(100) as asegurado,
			char(7)      as periodo,
            varchar(15)  as per_pago,
			char(10) 	 as licencia,
			char(10) 	 as no_poliza;

																																												  
--integer li_imp1, li_imp2, li_envi1, li_envi2, li_envi3, li_envi4																												  
--string ls_periodo,ls_poliza
begin

define _nombre_cliente	varchar(100);
define _nombre_plan     varchar(100);
define _direccion		varchar(50);
define _direccion2		varchar(50);
define _nombre_agente	varchar(50);
define _no_documento	char(20);
define _telefono1		char(10);
define _telefono2		char(10);
define _no_poliza		char(10);
define _celular      	char(10);
define _producto_act	char(5);
define _nom_prod_act    varchar(50);
define _producto_nvo	char(5);
define _nom_prod_nvo    varchar(50);
define _prima_act		dec(16,2);
define _prima_nvo		dec(16,2);
define _cod_agente		char(5);
define _fecha_aniv		date;
DEFINE _ls_autoriza     VARCHAR(20);
define _fecha_desde     date;
define _fecha_hasta     date;
define _verifica        smallint;
define v_nombre_firma   varchar(50);
define v_cargo          varchar(50);
define v_codigo_perfil  varchar(10);
define _prima_ant       dec(16,2);
define _cod_asegurado   char(10);
define _asegurado       varchar(100);
define _resolucion      varchar(40);
--define _porc_aumento    integer;
define _porc_aumento    dec(16,2);
define _cnt_rec         smallint;
define _plan            varchar(50);
DEFINE _cust_qry, _cust_qry2, _cust_qry3, _cust_qry4, _cust_qry5 LVARCHAR(500);
define _no_unidad       char(5);
define _prima_depen     dec(16,2);
define _porc_impuesto   dec(16,2);
--define _cambio_edad_t   integer;
--define _inf_suf_prima   integer;
define _cambio_edad_t   dec(5,2);
define _inf_suf_prima   dec(5,2);
define _diferencia      dec(16,2);
define _letra           integer;
define _siniestralidad  dec(16,2);
define _html			char(3000);
define _grupo           varchar(50);
define _pais            varchar(50); 
define _provincia       varchar(30); 
define _cargo           char(3);
define _cod_perpago     char(3);
define _per_pago        varchar(15);
define _meses           smallint;
define _mes_act         smallint;
define _no_licencia     char(10);

set isolation to dirty read;

let _fecha_desde = MDY(a_periodo[6,7], 1, a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo);


	 create temp table temp_carta2012
			  (nombre_cliente	char(100), 
			   direccion    	varchar(50), 
			   direccion2    	varchar(50), 
			   telefono1    	char(10),	
			   telefono2    	char(10),	
			   celular      	char(10),	
			   pais             varchar(50),
			   provincia        varchar(30),
			   no_documento		char(20),	
			   grupo            varchar(50),
			   fecha_aniv   	date,	
			   nombre_agente	char(50),	
			   producto_act 	char(5), 
			   nom_prod_act     varchar(50),
			   prima_act     	decimal(16,2),
			   producto_nvo 	char(5), 
			   nom_prod_nvo     varchar(50),
			   prima_nvo     	decimal(16,2),
			   asegurado        varchar(100),
               per_pago         varchar(15),
			   no_licencia		char(10),
			   no_poliza		char(10)
			) with no log;

			
	create index idx1_temp_carta2012 on temp_carta2012(no_documento);
--	create index idx2_temp_carta2012 on temp_carta2012(cod_subramo);
--	create index idx3_temp_carta2012 on temp_carta2012(periodo);
--	create index idx4_temp_carta2012 on temp_carta2012(zona);


-- Construct a Dynamic query using SPL argument table_name
let _cust_qry = "select distinct a.no_documento, c.nombre, c.direccion_1, c.direccion_2, c.telefono1, c.telefono2, c.celular, f.nombre, g.nombre, e.nombre,"; 
let _cust_qry = _cust_qry || "a.fecha_aniv, a.producto_act, a.prima_act, a.producto_nvo, a.prima_nvo, d.nombre "; 
let _cust_qry2 = "from emicartasal6 a, emipomae b, cliclien c, cligrupo d, cliclien e, genpais f, genprov g ";
let _cust_qry2 = _cust_qry2 || "where (a.no_documento = b.no_documento ) and (a.cod_contratante = c.cod_cliente ) and (a.cod_asegurado = e.cod_cliente) and a.cod_grupo = d.cod_grupo ";
let _cust_qry2 = _cust_qry2 || "and (c.code_pais = f.code_pais) and (c.code_pais = g.code_pais and c.code_provincia = g.code_provincia) and ((a.fecha_aniv >= ? and ";
let _cust_qry3 = "a.fecha_aniv <= ?) and (a.impreso	= ? or a.impreso = ?) and a.enviado_a in (?, ?, ?, ?) ";
let _cust_qry4 = " and a.no_documento like ?) and (b.estatus_poliza not in (2,4)) and (b.renovada = 0) and a.opcion = ?";
let _cust_qry5 = "order by a.no_documento asc";  --and a.user_added in ('AMADO','FANY') 	 

-- Prepare the above constructed query
-- Get the statement handle "statement_id"

PREPARE stmt_id FROM _cust_qry || _cust_qry2 || _cust_qry3 || _cust_qry4 || _cust_qry5;

-- Declare the cursor for the prepared "statement_id"
-- get the cursor handle "cust_cur"

DECLARE cust_cur cursor FOR stmt_id;

-- Open the declared cursor using handle "cust_cur"
-- Supply the first_name as an input. This will be
-- substituted in the place of "?" in the query

OPEN cust_cur USING _fecha_desde, _fecha_hasta, a_imp1, a_imp2, a_envi1, a_envi2, a_envi3, a_envi4, a_poliza, a_opcion;

WHILE (1 = 1)

-- Fetch a row from the cursor "cust_cur" and store
-- the returned column values to the SPL variables
FETCH cust_cur INTO _no_documento, _nombre_cliente, _direccion, _direccion2, _telefono1, _telefono2, _celular, _pais, _provincia, _asegurado, _fecha_aniv, _producto_act, _prima_act, _producto_nvo, _prima_nvo, _grupo;
-- Check if FETCH reached end-of-table (SQLCODE = 100)
-- if so, exit from while loop; else return the columns
-- and continue

IF (SQLCODE != 100) THEN
		if _no_documento in ('1813-00174-01','1813-00195-01') then
		--	set debug file to "sp_pro570.trc";
		--	trace on;
		end if

		let _no_poliza = sp_sis21(_no_documento);
	   
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 
			 exit foreach;
		end foreach
        
		select nombre,
			   no_licencia
		  into _nombre_agente,
			   _no_licencia
		  from agtagent
		 where cod_agente = _cod_agente;
		 
		select nombre
          into _nom_prod_act
          from prdprod
         where cod_producto = _producto_act;		  
		
		select nombre
          into _nom_prod_nvo
          from prdprod
         where cod_producto = _producto_nvo;		  
	     
        select cod_perpago
          into _cod_perpago
          from emipomae
         where no_poliza = _no_poliza;
         
        if _cod_perpago = '002' then
            let _per_pago = 'mensual';
        elif _cod_perpago = '003' then  
            let _per_pago = 'bimestral';  
        elif _cod_perpago = '004' then  
            let _per_pago = 'trimestral';  
        elif _cod_perpago in ('005','009') then  
            let _per_pago = 'cuatrimestral';  
        elif _cod_perpago = '007' then  
            let _per_pago = 'semestral';  
        elif _cod_perpago = '008' then  
            let _per_pago = 'anual';
		elif _cod_perpago = '006' then  
			let _per_pago = 'inmediata';
		else
			let _per_pago = '';
        end if 
        
     	select meses
    	  into _meses
    	  from cobperpa
    	 where cod_perpago = _cod_perpago;
    
        let _mes_act = _meses;
            
    	if _meses = 0 then
            let _mes_act = 1;
    		If _cod_perpago = '008' then  --Anual
    			let _meses = 12;
    		else
    			let _meses = 1;
    		End if
    	end if
    	
    	--let _prima_act = _prima_act * _mes_act;     
   	    --let _prima_nvo = _prima_nvo * _meses;     
		 
		insert into temp_carta2012(nombre_cliente, 
								   direccion, 
								   direccion2, 
								   telefono1,	
								   telefono2,	
								   celular,	
								   pais,
								   provincia,
								   no_documento,	
								   grupo,
								   fecha_aniv,	
								   nombre_agente,	
								   producto_act, 
								   nom_prod_act,
								   prima_act,
								   producto_nvo, 
								   nom_prod_nvo,
								   prima_nvo,
								   asegurado,
                                   per_pago,
								   no_licencia,
								   no_poliza
								  )  
					 values(    _nombre_cliente,  
								_direccion, 
								_direccion2,
								_telefono1, 
								_telefono2, 
								_celular, 
								_pais,
								_provincia,
								_no_documento,
								_grupo,
								_fecha_aniv, 
								_nombre_agente, 
								_producto_act, 
								_nom_prod_act,
								_prima_act, 
								_producto_nvo,
                                _nom_prod_nvo,								
								_prima_nvo, 
								_asegurado,
                                _per_pago,
								_no_licencia,
								_no_poliza
								 );	 
ELSE
-- break the while loop
	EXIT;
END IF

END WHILE

-- Close the cursor "cust_cur"

CLOSE cust_cur;

-- Free the resources allocated for cursor "cust_cur"

FREE cust_cur ;

-- Free the resources allocated for statement "statement_id"

FREE stmt_id ;

-- Busca Firma

SELECT valor_parametro 
  INTO _ls_autoriza
  FROM inspaag
 WHERE codigo_parametro = "firma_carta_salud"
   AND codigo_agencia   = '001';

SELECT descripcion,
       cia_depto,
	   cargo			
  INTO v_nombre_firma,
       v_codigo_perfil,
	   _cargo
  FROM insuser
 WHERE usuario = trim(_ls_autoriza);

select nombre
  into v_cargo
  from inscargo
 where cod_depto = v_codigo_perfil
   and cod_cargo = _cargo;

foreach
     select nombre_cliente, 
		    direccion, 
		    direccion2, 
		    telefono1,	
		    telefono2,	
		    celular,	
			pais,
			provincia,
		    no_documento,	
			grupo,
		    fecha_aniv,	
		    nombre_agente,	
		    producto_act, 
			nom_prod_act,
		    prima_act,
		    producto_nvo, 
			nom_prod_nvo,
		    prima_nvo,
		    asegurado,
            per_pago,
            no_licencia,
			no_poliza
       into _nombre_cliente,  
			_direccion, 
			_direccion2,
			_telefono1, 
			_telefono2, 
			_celular, 
			_pais,
			_provincia,
			_no_documento,
			_grupo,
			_fecha_aniv, 
			_nombre_agente, 
			_producto_act, 
			_nom_prod_act,
			_prima_act, 
			_producto_nvo, 
			_nom_prod_nvo,
			_prima_nvo, 
			_asegurado,
            _per_pago,
			_no_licencia,
			_no_poliza
       from temp_carta2012	
	  order by nombre_agente asc, no_documento asc   

	 return trim(_nombre_cliente),	--01
			trim(upper(_direccion)),			--02
			trim(upper(_direccion2)),
			_telefono1,			--03
			_telefono2,			--04
			_celular,			--05
			_pais,
			_provincia,
			_no_documento,		--06
			_grupo,
			_fecha_aniv,		--07
			trim(_nombre_agente),		--08
			_nom_prod_act,          --09
			_prima_act,				--10
			_nom_prod_nvo,			--11
			_prima_nvo,             --12
			_ls_autoriza,
			v_nombre_firma,
			v_cargo,
			trim(_asegurado),		--13	
            a_periodo,
            trim(_per_pago),
			trim(_no_licencia),
			trim(_no_poliza)
			with resume;


end foreach

drop table temp_carta2012;
end

end procedure  

 
		