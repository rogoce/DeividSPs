-- Procedimiento que se utuliza cuando se dispara el trigger. 
-- 
-- creado: 21/07/2015 - Autor: Jaime Chevalier

DROP PROCEDURE sp_leg02;
CREATE PROCEDURE "informix".sp_leg02()
REFERENCING OLD AS o NEW AS n FOR legdeman; 								  

DEFINE _fecha_nota          DATETIME HOUR TO FRACTION(5);
DEFINE _descripcion         VARCHAR(255);
DEFINE _nombre              VARCHAR(10);
DEFINE _nuevo               VARCHAR(20);
DEFINE _viejo               VARCHAR(20);
DEFINE _nombre_ins          VARCHAR(18);
DEFINE _nueva_ins           VARCHAR(18);
DEFINE _pro_nuevo           VARCHAR(12);
DEFINE _nombre_pro          VARCHAR(12); 
DEFINE _tipo_deman_nue      VARCHAR(14);
DEFINE _tipo_deman          VARCHAR(15);
DEFINE _cuantia_nuevo       DECIMAL(16,2);
DEFINE _cuantia_viejo       DECIMAL(16,2);
DEFINE _deman_nue           VARCHAR(50);
DEFINE _deman_viejo         VARCHAR(50);

LET _fecha_nota = CURRENT;

--Cuando se modifica el estatus de la demanda
If o.estatus_actual <> n.estatus_actual Then
	LET _fecha_nota = _fecha_nota + 1 units second;
    LET _descripcion = '';
	LET _nombre = '';
	LET _nuevo = '';
	
    If o.estatus_actual = 1 Then
		LET _nombre = 'EN CURSO';
		LET _nuevo = 'CERRADA';
	Else
		LET _nombre = 'CERRADA';
		LET _nuevo = 'EN CURSO';
	End If
	
	LET _descripcion = "SE MODIFICO EL ESTATUS DE LA DEMANDA DE " || _nombre || "  A  " || _nuevo;
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico); 
End If

--Cuando se modifica el expediente de la demanda
If o.expediente <> n.expediente  Then
	LET _fecha_nota = _fecha_nota + 1 units second;
    LET _descripcion = '';
    LET _nuevo = ''; 
	LET _viejo = ''; 
	
	LET _nuevo = n.expediente;
	If O.expediente IS NULL or O.expediente = '' Then
		LET _viejo = '-----';
	Else
		LET _viejo = O.expediente;
	End If
	
	LET _descripcion = "SE CAMBIO EL EXPEDIENTE DE  " || _viejo || " AL NUEVO EXPEDIENTE  " || _nuevo;
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico); 
End If

--Cuando se modifica la instancia de la demanda
If o.instancia <> n.instancia Then
	LET _fecha_nota = _fecha_nota + 1 units second;
	LET _descripcion = '';
	
    If o.instancia = 1 Then
		LET _nombre_ins = 'JUZGADO';
	ELIF o.instancia = 2 Then
		LET _nombre_ins = 'TRIBUNAL SUPERIOR';
	ELIF o.instancia = 3 Then
		LET _nombre_ins = 'CSJ';
	ELIF o.instancia = 4 Then
		LET _nombre_ins = 'MINISTERIO PUBLICO';
	End If
	
	If n.instancia = 1 Then
		LET _nueva_ins = 'JUZGADO';
	ELIF n.instancia = 2 Then
		LET _nueva_ins = 'TRIBUNAL SUPERIOR';
	ELIF n.instancia = 3 Then
		LET _nueva_ins = 'CSJ';
	ELIF n.instancia = 4 Then
		LET _nueva_ins = 'MINISTERIO PUBLICO';
	End If
	
	LET _descripcion = "LA DEMANDA PASO DE  " || _nombre_ins || "  A  " || _nueva_ins;
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico); 
End If

--Cuando se modifica el pronostico de la demanda
If o.pronostico <> n.pronostico Then
	LET _fecha_nota = _fecha_nota + 1 units second;
    LET _descripcion = '';
	LET _pro_nuevo = "";
	
    If o.pronostico = 0 Then
		LET _nombre_pro = 'POR DEFINIR';
	ELIF o.pronostico = 1 Then
		LET _nombre_pro = 'FAVORABLE';
	ELIF o.pronostico = 2 Then
		LET _nombre_pro = 'RESERVADO';
	ELIF o.pronostico = 3 Then
		LET _nombre_pro = 'DESFAVORABLE';
	End If
	
	If n.pronostico = 0 Then
		LET _pro_nuevo = 'POR DEFINIR';
	ELIF n.pronostico = 1 Then
		LET _pro_nuevo = 'FAVORABLE';
	ELIF n.pronostico = 2 Then
		LET _pro_nuevo = 'RESERVADO';
	ELIF n.pronostico = 3 Then
		LET _pro_nuevo = 'DESFAVORABLE';
	End If
	
	LET _descripcion = "SE MODIFICO EL PRONOSTICO DE LA DEMANDA DE  " || _nombre_pro || "  A  " || _pro_nuevo;
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico); 
End If

--Cuando se modifica el Jusgado de la demanda
If o.juzgado <> n.juzgado Then
	LET _fecha_nota = _fecha_nota + 1 units second;
    LET _descripcion = '';
	LET _viejo = '';
	LET _nuevo = '';
	
	If o.juzgado IS NULL or o.juzgado = ''  Then
		LET _viejo = "-------";
	Else
		select nombre 
		  into _viejo
		  from reclugci
		 where cod_lugci = o.juzgado;
	End If
	 
	select nombre 
	  into _nuevo
	  from reclugci
     where cod_lugci = n.juzgado;
	
	LET _descripcion = "SE MODIFICO EL JUZGADO DE LA DEMANDA DE  " || _viejo || "  A  " || _nuevo;
	--LET _descripcion = "SE MODIFICO EL JUZGADO DE LA DEMANDA DE  ";
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico); 
End If

--Cuando se modifica el Abogado de la demanda
If o.cod_abogado <> n.cod_abogado Then
	LET _fecha_nota = _fecha_nota + 1 units second;
    LET _descripcion = '';
	LET _viejo = '';
	LET _nuevo = '';
	
	If o.cod_abogado IS NULL or o.cod_abogado = '' or o.cod_abogado = '000' Then
		LET _viejo = "-------";
	Else
		select nombre_abogado 
		  into _viejo
	      from recaboga 
	     where cod_abogado = o.cod_abogado;
	End IF
	 
	select nombre_abogado 
	  into _nuevo
	  from recaboga 
	where cod_abogado = n.cod_abogado;
	
	LET _descripcion = "SE PROCEDIO A CAMBIAR EL ABOGADO DE LA DEMANDA DE  " || _viejo || "  A  " || _nuevo;
	--LET _descripcion = "PRUEBA";
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico); 
End If 

--Cuando se modifica el Numero de reclamo de la demanda
If o.numrecla <> n.numrecla Then
	LET _fecha_nota = _fecha_nota + 1 units second;
    LET _descripcion = '';
    LET _nuevo = ''; 
	LET _viejo = ''; 
	
	LET _nuevo = n.numrecla;
	LET _viejo = o.numrecla;
	
	LET _descripcion = "SE CAMBIO EL NUMERO DE RECLAMO DE  " || _viejo || " AL NUEVO NUMERO  " || _nuevo;
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico); 
End If 

--Cuando se modifica el tipo  de la demanda
If o.tipo_demanda <> n.tipo_demanda Then
	LET _fecha_nota = _fecha_nota + 1 units second;
    LET _descripcion = '';
	LET _tipo_deman_nue = "";
	LET _tipo_deman = "";
	
    If o.tipo_demanda = 0 Then
		LET _tipo_deman = 'POR DEFINIR';
	ELIF o.tipo_demanda = 1 Then
		LET _tipo_deman = 'CIVIL';
	ELIF o.tipo_demanda = 2 Then
		LET _tipo_deman = 'PENAL';
	ELIF o.tipo_demanda = 3 Then
		LET _tipo_deman = 'ADMINISTRATIVA';
	End If
	
	If n.tipo_demanda = 0 Then
		LET _tipo_deman_nue = 'POR DEFINIR';
	ELIF n.tipo_demanda = 1 Then
		LET _tipo_deman_nue = 'CIVIL';
	ELIF n.tipo_demanda = 2 Then
		LET _tipo_deman_nue = 'PENAL';
	ELIF n.tipo_demanda = 3 Then
		LET _tipo_deman_nue = 'ADMINISTRATIVA';
	End If
	
	LET _descripcion = "SE MODIFICO EL PRONOSTICO DE LA DEMANDA DE  " || _tipo_deman || "  A  " || _tipo_deman_nue;
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico); 
End If

--Cuando se modifica la cuantia de la demanda
If o.monto_cuantia <> n.monto_cuantia Then
	LET _fecha_nota = _fecha_nota + 1 units second;
    LET _descripcion = '';
    LET _cuantia_nuevo = ''; 
	LET _cuantia_viejo = ''; 
	
	LET _cuantia_nuevo = n.monto_cuantia;
	LET _cuantia_viejo = o.monto_cuantia;
	
	LET _descripcion = "SE MODIFICO EL MONTO DE LA CUANTIA DE  " || _cuantia_viejo || " A  " || _cuantia_nuevo;
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico);  
End If 

--Cuando se modifica el demandante de la demanda
If o.demandante <> n.demandante Then
	LET _fecha_nota = _fecha_nota + 1 units second;
    LET _descripcion = '';
    LET _deman_nue = ''; 
	LET _deman_viejo = ''; 
	
	LET _deman_nue = n.demandante;
	LET _deman_viejo = o.demandante;
	
	LET _descripcion = "SE CAMBIO EL NOMBRE DEL DEMANDANTE DE  " || _deman_viejo || " A " || _deman_nue;
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico); 
End If  

--Cuando se modifica el demandado de la demanda
If o.demandado <> n.demandado Then
	LET _fecha_nota = _fecha_nota + 1 units second;
    LET _descripcion = '';
    LET _deman_nue = ''; 
	LET _deman_viejo = ''; 
	
	LET _deman_nue = n.demandado;
	LET _deman_viejo = o.demandado;
	
	LET _descripcion = "SE CAMBIO EL NOMBRE DEL DEMANDADO DE " || _deman_viejo || "  A  " || _deman_nue;
	
	Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
                  values (o.no_demanda, _fecha_nota, _descripcion, n.user_modifico); 
End If  

END PROCEDURE
