------------------------------------------------
--      EMICARTASAL2          --
--         CONTRATO DE REASEGURO              --
---  Henry Giron - 10/12/2011 --
------------------------------------------------
drop procedure sp_pro570b;
create procedure sp_pro570b(a_periodo char(7),
                            a_opcion smallint,
							a_imp1 smallint default 0,
							a_imp2 smallint default 0,
							a_envi1 smallint default 0,
							a_envi2 smallint default 0,
							a_envi3 smallint default 0,
							a_envi4 smallint default 0,
							a_poliza char(20) default "%"
						   )
returning	varchar(100),
			varchar(50),
			varchar(50),
			char(10),
			char(10),
			char(10),
			char(20),
			char(3),
			char(3),
			char(3),
			date,
			varchar(50),
			char(5),
			dec(16,2),
			char(7),
			varchar(100),
			dec(16,2),
			dec(16,2),
			varchar(100),
			dec(16,2),
			char(100),
			varchar(20),
			varchar(50),
			varchar(50),
			dec(16,2),
			varchar(100),
			varchar(50),
			dec(5,2),
			dec(5,2);
																																												  
--integer li_imp1, li_imp2, li_envi1, li_envi2, li_envi3, li_envi4																												  
--string ls_periodo,ls_poliza
begin

define _nombre_zona		varchar(50);
define _nombre_cliente	varchar(100);
define _deducible_txt	char(100);
define _name_cliclien	varchar(100);
define _nombre_plan     varchar(100);
define _direccion		varchar(50);
define _direccion2		varchar(50);
define _nombre_agente	varchar(50);
define _no_documento	char(20);
define _deducible_din	char(18);
define _telefono1		char(10);
define _telefono2		char(10);
define _no_poliza		char(10);
define _celular      	char(10);
define _periodo			char(7);
define _cod_producto	char(5);
define _cod_agente		char(5);
define _cod_vendedor	char(3);
define _cod_formapag	char(3);
define _cod_subramo		char(3);
define _cod_perpago		char(3);
define _deducible_int	dec(16,2);
define _deducible		dec(16,2);
define _co_pago			dec(16,2);
define _prima			dec(16,2);
define _fecha_aniv		date;
DEFINE _ls_autoriza     CHAR(20);
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
define _porc_aumento    dec(16,2);
define _cnt_rec         smallint;
define _plan            varchar(50);
DEFINE _cust_qry, _cust_qry2, _cust_qry3, _cust_qry4 VARCHAR(250);
define _no_unidad       char(5);
define _prima_depen     dec(16,2);
define _porc_impuesto   dec(5,2);
define _cambio_edad_t   dec(16,2);
define _inf_suf_prima   dec(5,2);
define _diferencia      dec(16,2);
define _letra           integer;

set isolation to dirty read;

let _fecha_desde = MDY(a_periodo[6,7], 1, a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo);


--	set debug file to "sp_pro570.trc";
--	trace on;
	
drop table if exists temp_carta2012;

     create temp table temp_carta2012
			  (nombre_cliente	char(100), 
			   direccion    	varchar(50), 
			   direccion2    	varchar(50), 
			   telefono1    	char(10),	
			   telefono2    	char(10),	
			   celular      	char(10),	
			   no_documento		char(20),	
			   cod_subramo  	char(3),	
			   cod_formapag 	char(3),	
			   cod_perpago  	char(3),	
			   fecha_aniv   	date,	
			   nombre_agente	char(50),	
			   cod_producto 	char(5), 
			   prima      		decimal(16,2),
			   periodo    		char(7), 
			   name_cliclien    char(100),
			   deducible		dec(16,2),	
			   co_pago  		dec(16,2),	
			   nombre_plan      char(100),
			   deducible_int	dec(16,2),
			   deducible_txt    char(100),
			   zona             varchar(50),
			   prima_ant   		decimal(16,2),
			   asegurado        varchar(100),
			   resolucion       varchar(50),
			   porc_aumento     dec(5,2),
			   inf_suf_prima    dec(5,2)
            ) with no log;
										 
	create index idx1_temp_carta2012 on temp_carta2012(no_documento);
	create index idx2_temp_carta2012 on temp_carta2012(cod_subramo);
	create index idx3_temp_carta2012 on temp_carta2012(periodo);
	create index idx4_temp_carta2012 on temp_carta2012(zona);

if a_opcion = 1 then
 let _plan = "and a.cod_subramo in ('007','009')";
else
 let _plan = "and a.cod_subramo in ('008','018','016')";
end if	
let _plan = trim(_plan); 

-- Construct a Dynamic query using SPL argument table_name
let _cust_qry = "select distinct a.nombre_cliente, c.direccion_1, c.direccion_2, c.telefono1, c.telefono2, c.celular, a.no_documento, a.cod_subramo,"; 
let _cust_qry = _cust_qry || "a.cod_formapag, a.cod_perpago, a.fecha_aniv, a.nombre_agente, a.cod_producto, a.prima,"; 
let _cust_qry2 = "a.periodo, c.nombre, a.deducible, a.co_pago, a.nombre_plan, a.deducible_int from emicartasal2 a, emipomae b, cliclien c ";
let _cust_qry2 = _cust_qry2 || "where (a.no_documento = b.no_documento ) and (b.cod_contratante = c.cod_cliente ) and ((a.fecha_aniv >= ? and ";
let _cust_qry3 = "a.fecha_aniv <= ?) and (a.impreso	= ? or a.impreso = ?) and a.enviado_a in (?, ?, ?, ?) " || _plan;
let _cust_qry4 = " and a.no_documento like ?) and (a.tipo_cambio = 0) and (b.estatus_poliza not in (2,4)) order by a.nombre_agente asc, a.no_documento asc";  	 

-- Prepare the above constructed query
-- Get the statement handle "statement_id"

PREPARE stmt_id FROM _cust_qry || _cust_qry2 || _cust_qry3 || _cust_qry4;

-- Declare the cursor for the prepared "statement_id"
-- get the cursor handle "cust_cur"

DECLARE cust_cur cursor FOR stmt_id;

-- Open the declared cursor using handle "cust_cur"
-- Supply the first_name as an input. This will be
-- substituted in the place of "?" in the query

OPEN cust_cur USING _fecha_desde, _fecha_hasta, a_imp1, a_imp2, a_envi1, a_envi2, a_envi3, a_envi4, a_poliza;

WHILE (1 = 1)

-- Fetch a row from the cursor "cust_cur" and store
-- the returned column values to the SPL variables
FETCH cust_cur INTO _nombre_cliente, _direccion, _direccion2, _telefono1, _telefono2, _celular, _no_documento, _cod_subramo, _cod_formapag, _cod_perpago, _fecha_aniv, _nombre_agente, _cod_producto, _prima, _periodo, _name_cliclien, _deducible, _co_pago, _nombre_plan, _deducible_int;
if _no_documento = '1814-00285-01' then
--	set debug file to "sp_pro570.trc";
--	trace on;
end if
-- Check if FETCH reached end-of-table (SQLCODE = 100)
-- if so, exit from while loop; else return the columns
-- and continue

IF (SQLCODE != 100) THEN
       let _cambio_edad_t = sp_pro571b(_no_documento);
	   
	   let _diferencia = 0;
	   	   
	   let _inf_suf_prima = 4.40;
	   
	   let _deducible_din = _deducible_int ;

	   if _cod_subramo = "009" then  -- Para Global se adiciona el deducible intenacinal
			let _deducible_txt = " LOCAL B/. "||_deducible||" / Internacional B/. "||_deducible_din; --_deducible_int;
	   else
			let _deducible_txt = " B/. "||_deducible;
	   end if

	   let _no_poliza = sp_sis21(_no_documento);

		SELECT cod_perpago
		  INTO _cod_perpago
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
		 
	  if _cod_perpago = '008' then
	    let _letra = 12;
	  elif _cod_perpago = '001' then
	    let _letra = 1;
	  else
	    select meses 
		  into _letra
		  from cobperpa
		 where cod_perpago = _cod_perpago;
	  end if
	   
 --     let _prima = _prima * _letra;	  
	  
	  LET _prima_ant = 0;
	  
	  foreach
		select no_unidad,
		       prima_neta
		  into _no_unidad,
		       _prima_ant
		  from emipouni
		 where no_poliza = _no_poliza
		   and activo = 1
		exit foreach;
	  end foreach
	  
	 if _prima_ant is null then
		LET _prima_ant = 0;
	 end if
	
	 LET _prima_ant = _prima_ant / _letra;
	
	-- impuesto	
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = _no_poliza;

	if _porc_impuesto is null then
		let _porc_impuesto = 0;
	end if

	let _prima_ant = _prima_ant * (_porc_impuesto / 100) + _prima_ant; 
	
	
	  
--	  FOREACH
--		SELECT prima_bruta
--		  INTO _prima_ant
--		  FROM endedmae
--		 WHERE no_poliza = _no_poliza
--		   AND cod_endomov = '014'
--		   AND actualizado = 1
--		ORDER BY no_endoso DESC

--		EXIT FOREACH;
--	  END FOREACH
	  
--	  IF _prima_ant IS NULL THEN
--		SELECT prima_bruta
--		  INTO _prima_ant
--		  FROM emipomae
--		 WHERE no_poliza = _no_poliza;
--	  END IF
	  
{	   let _cnt_rec = 0;
	   
	   SELECT count(*)
		  INTO _cnt_rec
		  FROM emiunire
		 WHERE no_poliza = _no_poliza;
		 
	   if _cnt_rec =  0 then
		continue foreach;
	   end if
}
	   foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 
			 exit foreach;

	   end foreach

	   select cod_vendedor
	     into _cod_vendedor
		 from parpromo
        where cod_agente  = _cod_agente
		  and cod_agencia = '001'
		  and cod_ramo	  =	'018';

		  let _nombre_zona = "";

   	   select nombre
	     into _nombre_zona
	     from agtvende
	    where cod_vendedor = _cod_vendedor;
		
		select cod_asegurado
		  into _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza 
		   and activo = 1;
		 
		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_asegurado;
		
		let _resolucion = null;
		
		select resolucion
		  into _resolucion
		  from prdprod
		 where cod_producto = _cod_producto;
		 
		 if _resolucion is null then
			let _resolucion = "";
		 end if
		 
		 let _porc_aumento = ((_prima / _prima_ant) - 1) * 100;
		 
		 let _porc_aumento = _porc_aumento;
		 let _cambio_edad_t = _cambio_edad_t;
		 let _inf_suf_prima = _inf_suf_prima;
		 let _diferencia = _porc_aumento - (_inf_suf_prima + _cambio_edad_t);
		 
		 let _inf_suf_prima = _inf_suf_prima + _diferencia;
		
	   
		   	insert into temp_carta2012(nombre_cliente,
			                        direccion,
									direccion2,
									telefono1,    	
									telefono2,    	
									celular,      	
									no_documento,		
									cod_subramo, 	
									cod_formapag, 	
									cod_perpago,	
									fecha_aniv,	
									nombre_agente,	
									cod_producto,	
									prima,	
						            periodo,	
									name_cliclien,
									deducible,		
									co_pago,  		
									nombre_plan,
									deducible_int,
									deducible_txt,
									zona,
                                    prima_ant,
                                    asegurado,
                                    resolucion,
                                    porc_aumento,
                                    inf_suf_prima									
									  )  
			    	     values(    _nombre_cliente,  
							  		_direccion, 
									_direccion2,
							  		_telefono1, 
							  		_telefono2, 
							  		_celular, 
							  		_no_documento,
							  		_cod_subramo, 
							  		_cod_formapag, 
							  		_cod_perpago, 
			    			  		_fecha_aniv, 
			    			  		_nombre_agente, 
			    			  		_cod_producto, 
			    			  		_prima, 
			    			  		_periodo, 
			     			  	  	_name_cliclien,
			     			  	  	_deducible,		
			     			  	  	_co_pago,  		
			     			  	  	_nombre_plan,
									_deducible_int,
									_deducible_txt,
									_nombre_zona,
									_prima_ant,
									_asegurado,
									_resolucion,
									_porc_aumento,
									_inf_suf_prima
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
   
select descripcion, codigo_perfil
  into v_nombre_firma, v_codigo_perfil
  from insuser 
 where usuario = trim(_ls_autoriza);
 
select descripcion
  into v_cargo
  from inspefi 
 where codigo_perfil = v_codigo_perfil;


foreach
     select nombre_cliente,
			direccion,
            direccion2,			
			telefono1,    	
			telefono2,    	
			celular,      	
			no_documento,	
			cod_subramo, 	
			cod_formapag, 	
			cod_perpago,	
			fecha_aniv,	
			nombre_agente,	
			cod_producto,	
			prima,	
			periodo,	
			name_cliclien,
	  	  	deducible,		
	  	  	co_pago,  		
	  	  	nombre_plan,
	  	  	deducible_int,
	  	  	deducible_txt,
	  	  	zona,
            prima_ant,
			asegurado,
			resolucion,
			porc_aumento,
            inf_suf_prima			
       into _nombre_cliente,
			_direccion, 
			_direccion2,
			_telefono1, 
			_telefono2, 
			_celular, 
	        _no_documento, 
			_cod_subramo, 
			_cod_formapag, 
			_cod_perpago, 
			_fecha_aniv, 
			_nombre_agente, 
			_cod_producto, 
			_prima, 
			_periodo, 
			_name_cliclien,
	  	  	_deducible,		
	  	  	_co_pago,  		
	  	  	_nombre_plan,
	  	  	_deducible_int,
	  	  	_deducible_txt,
			_nombre_zona,
			_prima_ant,
			_asegurado,
			_resolucion,
			_porc_aumento,
			_inf_suf_prima
       from temp_carta2012	
	  where porc_aumento < 0
	    or  _inf_suf_prima < 0
	  order by nombre_agente asc, zona, no_documento asc   

	         return trim(_nombre_cliente),	--01
					trim(_direccion),			--02
					trim(_direccion2),
					_telefono1,			--03
					_telefono2,			--04
					_celular,			--05
			        _no_documento,		--06
					_cod_subramo,		--07
					_cod_formapag,		--08
					_cod_perpago,		--09
					_fecha_aniv,		--10
					trim(_nombre_agente),		--11
					_cod_producto,		--12
					_prima,				--13
					_periodo,			--14
					trim(_name_cliclien),		--15
			  	  	_deducible,			--16		
			  	  	_co_pago,			--17  		
			  	  	trim(_nombre_plan),		--18
					_deducible_int,		--19
					_deducible_txt,		--20
					_ls_autoriza,		--21
					v_nombre_firma,
					v_cargo,
					_prima_ant,
					_asegurado,
					trim(_resolucion),
					_porc_aumento,
                    _inf_suf_prima					
	                with resume;


end foreach

drop table temp_carta2012;
end

end procedure  

 
		