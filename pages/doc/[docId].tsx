import { useRouter } from "next/router"
import { useEffect } from "react"
import DocumentEditor from "src/components/editor"
import Flex from "src/components/Flex"
import AppLayout from "src/components/layouts/AppLayout"
import TransitionOpacity from "src/components/TransitionOpacity"
import Loader from "src/components/ui/Loader"
import Typography from "src/components/ui/Typography"
import { useGetDocumentsQuery } from "src/services/documents"
import { useGetFoldersQuery } from "src/services/folders"
import { useAppDispatch } from "src/store"
import { setActiveDocument, setActiveFolder } from "src/store/navigation"
import { useUser, withPageAuth } from "src/utils/supabase"

function Document() {
    const router = useRouter()
    const { docId } = router.query as { docId: string }
    const user = useUser()

    const { document, isDocumentLoading } = useGetDocumentsQuery(null, {
        selectFromResult: ({ data, isLoading, isUninitialized }) => ({
            document: data?.find((d) => d.id === docId),
            isDocumentLoading: isUninitialized || isLoading
        }),
        skip: !user
    })

    const { folder } = useGetFoldersQuery(null, {
        selectFromResult: ({ data }) => ({
            folder: data?.find((f) => f.id === document?.folder)
        }),
        skip: !user
    })

    const dispatch = useAppDispatch()

    useEffect(() => {
        dispatch(setActiveDocument(document?.id))
        dispatch(setActiveFolder(folder?.id))

        return () => {
            dispatch(setActiveDocument(null))
            dispatch(setActiveFolder(null))
        }
    }, [document, folder, dispatch])

    return (
        <TransitionOpacity>
            {!!document && !!user ? (
                <DocumentEditor
                    documentId={docId}
                    user={{ email: user.email }}
                />
            ) : (
                <Flex
                    align="center"
                    justify="center"
                    style={{ width: "100%", height: "100%" }}
                >
                    {!!isDocumentLoading ? (
                        <Loader size="large" />
                    ) : (
                        <Typography.Text>
                            Ce document n&apos;existe pas. Il a peut-être été
                            supprimé.
                        </Typography.Text>
                    )}
                </Flex>
            )}
        </TransitionOpacity>
    )
}

Document.Layout = AppLayout
Document.Title = "Document"

export const getServerSideProps = withPageAuth()

export default Document
