using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class PlanarDissolve : MonoBehaviour
{
    [SerializeField]
    private bool useWorldSpace;

    [Header("Plane"), SerializeField]
    private Vector3 planePoint;
    [SerializeField]
    private Vector3 planeDirection;

    [Space(), SerializeField]
    private Color planeColor;
    [SerializeField]
    private Vector2 planePreviewSize;

    private Renderer rend;
    private int pointID;
    private int normalID;

    private void OnEnable()
    {
        rend = GetComponent<Renderer>();
        pointID = Shader.PropertyToID("_PlanePoint");
        normalID = Shader.PropertyToID("_PlaneNormal");
    }

    private void Update()
    {
        rend.sharedMaterial.SetVector(pointID, PlanePoint);
        rend.sharedMaterial.SetVector(normalID, PlaneNormal);
    }


    public Vector3 PlaneNormal { get { return Quaternion.Euler(planeDirection) * (useWorldSpace ? Vector3.up : transform.up); } }
    public Vector3 PlaneTangent { get { return Quaternion.Euler(planeDirection) * (useWorldSpace ? Vector3.right : transform.right); } }
    public Vector3 PlanePoint { get { return useWorldSpace ? planePoint : transform.TransformPoint(planePoint); } }

    private void DrawPlane()
    {
        Handles.zTest = UnityEngine.Rendering.CompareFunction.LessEqual;
        Vector3 tangent1 = PlaneTangent * planePreviewSize.x;
        Vector3 tangent2 = Vector3.Cross(PlaneTangent, PlaneNormal) * planePreviewSize.y;
        Handles.DrawSolidRectangleWithOutline
        (
            new Vector3[]
            {
                tangent1 + tangent2 + PlanePoint,
                tangent1 - tangent2 + PlanePoint,
                -tangent1 - tangent2 + PlanePoint,
                -tangent1 + tangent2 + PlanePoint
            },
            planeColor,
            planeColor
        );        
    }

    private void OnDrawGizmosSelected()
    {
        DrawPlane();
    }
}